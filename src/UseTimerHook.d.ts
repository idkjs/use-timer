interface IFinishedCallback {
    (): void
  }
  
  interface IUseTimerResult {
    minutes: string
    seconds: string
    start: () => void
    pause: () => void
    finished: (func: IFinishedCallback) => void
    reset: () => void
    setTimer: (newTimer: string) => void
  }
  
  declare function useTimer(stringTime: string): IUseTimerResult
  
  export default useTimer
  declare module '@idkjs/use-timer'
