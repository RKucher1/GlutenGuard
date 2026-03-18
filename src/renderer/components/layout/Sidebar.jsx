import { NavLink } from 'react-router-dom'

const navItems = [
  { to: '/',          icon: '◫', label: 'Day' },
  { to: '/week',      icon: '⊞', label: 'Week' },
  { to: '/dashboard', icon: '▦', label: 'Dashboard' },
  { to: '/settings',  icon: '⚙', label: 'Settings' },
]

export default function Sidebar() {
  return (
    <div className="flex flex-col items-center w-14 bg-[#0D1B2A] h-screen py-4 flex-shrink-0 border-r border-[#1A2F4A]">
      <div className="font-bold text-lg mb-8 select-none" style={{ color: '#4CB8CC' }}>DF</div>
      <nav className="flex flex-col items-center gap-2 w-full">
        {navItems.map(({ to, icon, label }) => (
          <NavLink
            key={to}
            to={to}
            end={to === '/'}
            className={({ isActive }) =>
              `w-full flex items-center justify-center h-10 text-xl transition-colors relative
               ${isActive
                 ? 'border-l-2'
                 : 'text-gray-500 hover:text-gray-300'
               }`
            }
            style={({ isActive }) => isActive ? { color: '#4CB8CC', borderColor: '#C87941' } : {}}
            title={label}
          >
            {icon}
          </NavLink>
        ))}
      </nav>
    </div>
  )
}
