import { useContext } from 'react'
import { AuthContext } from '../context/AuthContext'
import OrderHistory from '../components/OrderHistory'

export default function OrderHistoryPage() {
  const { user } = useContext(AuthContext)

  if (!user) {
    return <div>Loading...</div>
  }

  return <OrderHistory userId={user.id} />
}
