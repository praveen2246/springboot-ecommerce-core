import { useContext } from 'react'
import { useNavigate } from 'react-router-dom'
import { AuthContext } from '../context/AuthContext'
import Cart from '../components/Cart'

export default function CartPage() {
  const { user } = useContext(AuthContext)
  const navigate = useNavigate()

  if (!user) {
    return <div>Loading...</div>
  }

  return (
    <Cart 
      userId={user.id}
      onCheckoutClick={() => {
        navigate('/checkout')
      }}
      onOrderSuccess={() => {
        navigate('/orders')
      }}
    />
  )
}
