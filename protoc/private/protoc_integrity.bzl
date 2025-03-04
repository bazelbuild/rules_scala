"""Protocol compiler build and integrity metadata.

Generated and updated by scripts/update_protoc_integrity.py.
"""

PROTOC_RELEASES_URL = "https://github.com/protocolbuffers/protobuf/releases"
PROTOC_DOWNLOAD_URL = (
    PROTOC_RELEASES_URL +
    "/download/v{version}/protoc-{version}-{platform}.zip"
)

PROTOC_VERSIONS = [
    "29.3",
    "29.2",
    "29.1",
    "29.0",
    "28.3",
    "28.2",
]

PROTOC_BUILDS = {
    "linux-aarch_64": {
        "exec_compat": [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        "integrity": {
            "29.3": "sha256-ZCc0kUDgHwbgSecHpYcJpPIhrnOrmgQlvEoAyNDhqzI=",
            "29.2": "sha256-Kc9IPi+yGCfl+sSWTjXq5HKiOOKMdi8C+xfc2T/4uJ8=",
            "29.1": "sha256-H3Sj8zVd58Bma8ElYRwTUywlmPhTUh0NPmIaWwnyR5k=",
            "29.0": "sha256-MF8b5a57LzlFGHCzErRcHguiaZAcg7oW2F+fnRRBs0g=",
            "28.3": "sha256-HeUiAyqLGUAC/jXKuG10eEgji15N5PmWSDcgefW0b5o=",
            "28.2": "sha256-kdglPNwPDw/FHCtpyAZ3mWYy9SWthFBL+ltO44rT5Jw=",
        },
    },
    "linux-ppcle_64": {
        "exec_compat": [
            "@platforms//os:linux",
            "@platforms//cpu:ppc64le",
        ],
        "integrity": {
            "29.3": "sha256-DpiU7C45krFNGD586sFkZdam7nPh0jRpXYDm0elHAUw=",
            "29.2": "sha256-uiCJWht/NKb/ql5Rw0ExbErrxMFEN3hjQITpn262f/k=",
            "29.1": "sha256-B1vWZq1B60BKkjv6+pCkr6IHSiyaqLnHfERF5hbo75s=",
            "29.0": "sha256-EJAnjNB1e3AsNrA+6t9KvTYCAnm7B7DfX4C9iW8+IDM=",
            "28.3": "sha256-dSKdPN5z5wYZcXgU9R+m9K16NiwzUe5ZGXuxV8sAgsY=",
            "28.2": "sha256-xcFrR2f/iGYJDuEOhwkDABBSAbXbHs7zgO3XPCM03Ng=",
        },
    },
    "linux-s390_64": {
        "exec_compat": [
            "@platforms//os:linux",
            "@platforms//cpu:s390x",
        ],
        "integrity": {
            "29.3": "sha256-Y3hX/bqwsTNL2ysIcz8L5JaF5pMBG2EEgJSRrGL71NU=",
            "29.2": "sha256-LwpVmdprgpMqCNQz+nkTux1oWIl8zTxrwyhvAYt2xOA=",
            "29.1": "sha256-J5fNVlyn/7/ALaVsygE7/0+X5oMkizuZ3PfUuxf27GE=",
            "29.0": "sha256-LhXZqwaFbCXKbeYi4RR4XZGHHb25HCwQPrYouH8m3Ew=",
            "28.3": "sha256-jhtvqCX7CVlqiS5d6bgRLXoJtL3ftxzLv1+GgKT1aKc=",
            "28.2": "sha256-ESIsQ4+G6Hsv2vaKKmzB2ytiKBP9btiRUJ4vOw4F7hs=",
        },
    },
    "linux-x86_32": {
        "exec_compat": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_32",
        ],
        "integrity": {
            "29.3": "sha256-VGzx5pHOc/ZuKZzCLN1aF8YaEf5LbV34UHUHg4nx/Ck=",
            "29.2": "sha256-FU+NR+6YO8bxoa4tsUl+53E8Qt7vY1EXDxhmG/vNouw=",
            "29.1": "sha256-nd/EAbEqC4dHHg4POg0MKpByRj8EFDUUnpSfiiCCu+s=",
            "29.0": "sha256-tKyBCfKrSGLV5WuH4/cVMPug46YeyLnZQOKUdskGAQE=",
            "28.3": "sha256-DJ6zLLnl06rHLGfPc38In+Mr8kVssBc+EpWQfNGIXhI=",
            "28.2": "sha256-ucjToo5Lq5WcwQ5smjjxfFlGc3Npv+AT9RqG19Ns//E=",
        },
    },
    "linux-x86_64": {
        "exec_compat": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        "integrity": {
            "29.3": "sha256-PoZmIMW+J2ZPPS+i1la18+CbUVK0Lxvtv0J7Mz6QAho=",
            "29.2": "sha256-Uunn7OVcfjDn6LvSVLSyG0CKUwm8qCZ2PHEktpahMuk=",
            "29.1": "sha256-AMg/6XIthelsgblBsp8Xp0SzO0zmbg8YAJ/Yk33iLGA=",
            "29.0": "sha256-PFEGWvO5pgbZ4Yob9igUNzT/S55pcl1kWYV0MLp6eN8=",
            "28.3": "sha256-CtlJ8EpqF02oPNy9s23uCkklJypbbYP3mmv5hSB21T8=",
            "28.2": "sha256-L+v9QrWc6Too63iQGaRwo90ESWGbwE+E2tEzPaJh3sE=",
        },
    },
    "osx-aarch_64": {
        "exec_compat": [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
        "integrity": {
            "29.3": "sha256-K4o0A80Jf5XzumVuFLdscytrJtfxgzMLEeNu8rwCh2U=",
            "29.2": "sha256-DhU6ONbaGVlMmA5/fNPqDd1SydoQaMA8DYUzNp+/6yA=",
            "29.1": "sha256-uP1ZdpJhmKfE6lxutL94lZ1frtJ7/GGCVMqhBD93BEU=",
            "29.0": "sha256-srWfA7AwyKdIYj1oKotbycwJnkvP0GuJZM6J7AZbMQM=",
            "28.3": "sha256-ks7v2mpyk+wBTm7KyC1kcZNXFFy2/ChlutreteYsBDE=",
            "28.2": "sha256-e7BI9ShBeJ2exhmDvgzkyeT7O9mhQ0YoILqaO+CgN5c=",
        },
    },
    "osx-x86_64": {
        "exec_compat": [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
        "integrity": {
            "29.3": "sha256-mniANtj5hU97A8MF30d3zw5U5bCB4lvxUlLah+DpCHU=",
            "29.2": "sha256-uivZg7XwbsONZjtgKISll96jmQpDgD1+FT7Y98VCaeE=",
            "29.1": "sha256-2wK0uG3k1MztPqmTQ0faKNyV5/OIY//EzjzCYoMCjaY=",
            "29.0": "sha256-56HP/ILiHapngzARRJxw3f8eujsRWTQ4fm6BQe+rCS8=",
            "28.3": "sha256-l/5dRCCQtNvCPNE4T7m0RPodxuZ9FbteH+TeDadjiyA=",
            "28.2": "sha256-Iy8H0Sv0gGIHp57CxzeDAcUuby9+/dIcDdQW8L2hA+w=",
        },
    },
    "win32": {
        "exec_compat": [
            "@platforms//os:windows",
            "@platforms//cpu:x86_32",
        ],
        "integrity": {
            "29.3": "sha256-x8gCjBxNgBxTYCkg8shokgVAhr2WW2sjpLqV0hHcsdQ=",
            "29.2": "sha256-73CfcaUbOompsm3meCBc7zyV4h0IGLFn+/WwOackr9E=",
            "29.1": "sha256-EQXg+mRFnwsa9e5NWHfauGTy4Q2K6wRhjytpxsOm7QM=",
            "29.0": "sha256-154nzOTEAXRUERc8XraBFsPiBACxzEwt0stHeneUGP4=",
            "28.3": "sha256-sI/m/M9DE+LMxv1ybchV7okFM+JH9MVDyYf/2YDP1bI=",
            "28.2": "sha256-V6hpbqvtUgl19PpGkUGwuC+iEIYj0YtyOqi+yae0u1g=",
        },
    },
    "win64": {
        "exec_compat": [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        "integrity": {
            "29.3": "sha256-V+pZ6fVRrY1x/6qbXPvgyh9Ocglyodt+wtEqtEv/k4M=",
            "29.2": "sha256-Weph77JLnYohQXHiyj/sVcPxUX7/BnZWyHXYoc0Gzk8=",
            "29.1": "sha256-fqSCJYV//BIkWIwzXCsa+deKGK+dV8BSjMoxk+M26c4=",
            "29.0": "sha256-0DuSGYWLikyogGO3i/Clzec7UYCLkwxLZvBuhILDq+Y=",
            "28.3": "sha256-zmT0m97d70nOS9MTqPWbz5L89ntYMe+/ZhcDhtLmaUg=",
            "28.2": "sha256-S94ZJx7XyrkANXDyjG5MTXGWPq8SEahr87sl2biVF3o=",
        },
    },
}
