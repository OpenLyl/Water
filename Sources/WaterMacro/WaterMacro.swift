// macros

@attached(peer, names: prefixed(_))
//@attached(accessor)
public macro Computed() = #externalMacro(module: "WaterMacros", type: "ComputedMacro")
