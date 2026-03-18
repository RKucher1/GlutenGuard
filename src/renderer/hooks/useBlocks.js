import { useEffect } from 'react'
import useScheduleStore from '../store/useScheduleStore'

export default function useBlocks() {
  const { blocks, isLoading, error, loadToday, selectedDate } = useScheduleStore()

  useEffect(() => {
    loadToday()
  }, [])

  return { blocks, isLoading, error, selectedDate }
}
