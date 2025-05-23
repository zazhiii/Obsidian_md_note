# `Application`的生命周期

`init()`
`start()`
`stop()`

他们运行在不同的线程

```
init() 运行在：JavaFX-Launcher
start() 运行在：JavaFX Application Thread
stop() 运行在：JavaFX Application Thread
```

# `Stage`

窗口