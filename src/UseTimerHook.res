type useTimerResult = {
  minutes: string,
  seconds: string,
  start: unit => unit,
  reset: unit => unit,
  setTimer: string => unit,
  finished: (unit => unit) => unit,
  pause: unit => unit,
}

let useTimer: string => useTimerResult = stringTime => {
  let timer = React.useRef(None)
  // simple function to convert a string to a number
  // let twoChars = number => number < 10 ? `0${string_of_int(number)}` : string_of_int(number)

  // convert a number to a string with useCallback. Suggested for mounted components
  let twoChars = React.useCallback0(number => {
    "" ++ (number < 10 ? `0${string_of_int(number)}` : string_of_int(number))
  })

  let (minutes, seconds) = {
    switch stringTime->Js.String2.split(":") {
    | [hoursStr, minutesStr] =>
      switch (int_of_string_opt(hoursStr), int_of_string_opt(minutesStr)) {
      | (Some(minutes), Some(seconds)) => (minutes, seconds)
      | _ => (0, 0)
      }
    | _ => (0, 0)
    }
  }

  let getInitialTime = React.useCallback3(() => {
    (minutes->twoChars, seconds->twoChars)
  }, (minutes, seconds, twoChars))

  let ((minutes, seconds), setTime) = React.useState(_ => getInitialTime())

  let hasFinished = int_of_string(minutes) == 0 && int_of_string(seconds) == 0

  let start = React.useCallback1(() => {
    switch timer.current {
    | Some(current) => Js.Global.clearInterval(current)
    | None => timer.current = Some(Js.Global.setInterval(() =>
          setTime(time => {
            let (minutes, seconds) = time

            let _minutes = twoChars(
              if int_of_string(seconds) == 0 && int_of_string(minutes) > 0 {
                int_of_string(minutes) - 1
              } else {
                int_of_string(minutes)
              },
            )
            let _seconds = twoChars(
              if int_of_string(seconds) == 0 {
                59
              } else {
                int_of_string(seconds) - 1
              },
            )
            (_minutes, _seconds)
          })
        , 1000))
    }
  }, [twoChars])

  let pause = React.useCallback0(() => {
    switch timer.current {
    | Some(intervalId) =>
      intervalId->Js.Global.clearInterval
      timer.current = None
    | None => ()
    }
  })

  let finished = React.useCallback1(func => {
    switch hasFinished {
    | true => func()
    | false => ()
    }
  }, [hasFinished])

  let reset = React.useCallback1(() => {
    setTime(_ => getInitialTime())
  }, [getInitialTime])

  let setTimer = React.useCallback1(stringTime => {
    let (minutes, seconds) = {
      switch stringTime->Js.String2.split(":") {
      | [hoursStr, minutesStr] =>
        switch (int_of_string_opt(hoursStr), int_of_string_opt(minutesStr)) {
        | (Some(minutes), Some(seconds)) => (minutes, seconds)
        | _ => (0, 0)
        }
      | _ => (0, 0)
      }
    }

    setTime(_ => {
      (twoChars(minutes), twoChars(seconds))
    })
  }, [twoChars])

  React.useEffect1(() => {
    if hasFinished {
      switch timer.current {
      | Some(intervalId) =>
        let _ = Some(intervalId->Js.Global.clearInterval)
      | None => ()
      }
    }
    None
  }, [hasFinished])

  {
    minutes: minutes,
    seconds: seconds,
    start: start,
    pause: pause,
    finished: finished,
    reset: reset,
    setTimer: setTimer,
  }
}


