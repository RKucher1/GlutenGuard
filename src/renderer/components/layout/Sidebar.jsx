import { NavLink } from 'react-router-dom'

const navItems = [
  { to: '/',          icon: '◫', label: 'Day' },
  { to: '/week',      icon: '⊞', label: 'Week' },
  { to: '/dashboard', icon: '▦', label: 'Dashboard' },
  { to: '/settings',  icon: '⚙', label: 'Settings' },
]

export default function Sidebar() {
  return (
    <div className="flex flex-col items-center w-14 bg-[#0d1f3c] h-screen py-4 flex-shrink-0">
      <div className="text-[#00E5FF] font-bold text-lg mb-8 select-none">DF</div>
      <nav className="flex flex-col items-center gap-2 w-full">
        {navItems.map(({ to, icon, label }) => (
          <NavLink
            key={to}
            to={to}
            end={to === '/'}
            className={({ isActive }) =>
              `w-full flex items-center justify-center h-10 text-xl transition-colors relative
               ${isActive
                 ? 'text-[#00E5FF] border-l-2 border-[#00E5FF]'
                 : 'text-gray-500 hover:text-gray-300'
               }`
            }
            title={label}
          >
            {icon}
          </NavLink>
        ))}
      </nav>
    </div>
  )
}
