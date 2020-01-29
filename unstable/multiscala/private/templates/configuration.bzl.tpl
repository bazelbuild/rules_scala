# -*- mode: python -*-

def _from_json():
    # starlark vs json ...

    true = True
    false = False
    null = None

    return %{STARLARK_STRING}

configuration = _from_json()

def versions():
    return configuration["scala"].values()
