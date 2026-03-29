import { createContext, useState, useEffect } from 'react'
import axios from 'axios'
import API from '../services/api'

export const AuthContext = createContext()

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [token, setToken] = useState(localStorage.getItem('token'))
  const [loading, setLoading] = useState(false)
  const [isAuthenticated, setIsAuthenticated] = useState(!!token)

  // Configure axios and validate token on mount
  useEffect(() => {
    // Configure axios with token if available
    if (token) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
      API.defaults.headers.common['Authorization'] = `Bearer ${token}`
      localStorage.setItem('token', token)
      setIsAuthenticated(true)
    } else {
      delete axios.defaults.headers.common['Authorization']
      delete API.defaults.headers.common['Authorization']
      localStorage.removeItem('token')
      setIsAuthenticated(false)
    }
  }, [token])

  const register = async (username, email, password, confirmPassword, firstName, lastName) => {
    try {
      setLoading(true)
      const response = await API.post('/api/auth/register', {
        username,
        email,
        password,
        confirmPassword,
        firstName,
        lastName
      })
      
      if (response.data.success) {
        setToken(response.data.token)
        setUser(response.data.user)
        return { success: true, message: response.data.message }
      }
      return { success: false, message: response.data.message }
    } catch (error) {
      return {
        success: false,
        message: error.response?.data?.message || 'Registration failed'
      }
    } finally {
      setLoading(false)
    }
  }

  const login = async (email, password) => {
    try {
      setLoading(true)
      const response = await API.post('/api/auth/login', {
        email,
        password
      })
      
      if (response.data.success) {
        setToken(response.data.token)
        setUser(response.data.user)
        return { success: true, message: response.data.message }
      }
      return { success: false, message: response.data.message }
    } catch (error) {
      return {
        success: false,
        message: error.response?.data?.message || 'Login failed'
      }
    } finally {
      setLoading(false)
    }
  }

  const logout = () => {
    setToken(null)
    setUser(null)
    setIsAuthenticated(false)
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    delete axios.defaults.headers.common['Authorization']
    delete API.defaults.headers.common['Authorization']
  }

  const validateToken = async () => {
    if (!token) {
      setIsAuthenticated(false)
      return false
    }

    try {
      const response = await axios.get('/api/auth/validate', {
        headers: { Authorization: `Bearer ${token}` }
      })
      
      if (response.data.success) {
        setUser(response.data.user)
        setIsAuthenticated(true)
        return true
      }
    } catch (error) {
      setToken(null)
      setIsAuthenticated(false)
    }
    return false
  }

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        loading,
        isAuthenticated,
        register,
        login,
        logout,
        validateToken
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}
