def run_phases(ctx, phases):
    global_provider = {}
    current_provider = struct(**global_provider)
    for (name, function) in phases:
        new_provider = function(ctx, current_provider)
        if new_provider != None:
            global_provider[name] = new_provider
            current_provider = struct(**global_provider)

    return current_provider
