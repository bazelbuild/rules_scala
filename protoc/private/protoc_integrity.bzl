"""Protocol compiler build and integrity metadata.

Generated and updated by scripts/update_protoc_integrity.py.
"""

PROTOC_RELEASES_URL = "https://github.com/protocolbuffers/protobuf/releases"
PROTOC_DOWNLOAD_URL = (
    PROTOC_RELEASES_URL +
    "/download/v{version}/protoc-{version}-{platform}.zip"
)

PROTOC_VERSIONS = [
    "31.0",
    "30.2",
    "30.1",
    "30.0",
    "29.3",
    "29.2",
    "29.1",
    "29.0",
]

PROTOC_BUILDS = {
    "linux-aarch_64": {
        "exec_compat": [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        "integrity": {
            "31.0": "sha256-mZ9MAjNmsLaMXGUnLq14d+R6JnAkWnmQS4NFBXXafhk=",
            "30.2": "sha256-oxc+ozjvkbFgW4jE+BINbIzPNvdE2QgZkdWV0NQ1KZY=",
            "30.1": "sha256-6GbT3Ed16AMnIZFeg+P7bhq03vcZmkm0+VxNH2z0wDo=",
            "30.0": "sha256-WrNHtx+4qHE5zsNqrEvQ7jrD9PKvn8aOvfVW4cCmZcY=",
            "29.3": "sha256-ZCc0kUDgHwbgSecHpYcJpPIhrnOrmgQlvEoAyNDhqzI=",
            "29.2": "sha256-Kc9IPi+yGCfl+sSWTjXq5HKiOOKMdi8C+xfc2T/4uJ8=",
            "29.1": "sha256-H3Sj8zVd58Bma8ElYRwTUywlmPhTUh0NPmIaWwnyR5k=",
            "29.0": "sha256-MF8b5a57LzlFGHCzErRcHguiaZAcg7oW2F+fnRRBs0g=",
        },
    },
    "linux-ppcle_64": {
        "exec_compat": [
            "@platforms//os:linux",
            "@platforms//cpu:ppc64le",
        ],
        "integrity": {
            "31.0": "sha256-jrbKYaWRhND12vHIfUnemdW5PudWxxIbxRS/NbRxSgg=",
            "30.2": "sha256-6eTFvQF5CNxmeBg1egQkceyYVVkTBDWA0kBmFnjdhLM=",
            "30.1": "sha256-QvDGG3d9y7nSMb+ty43iz/vgYl4WFH2+oOdmeFpB60Q=",
            "30.0": "sha256-yWGN4tFeIPFn0yaozAed/R8ETAVeDIv7eJ428guEktM=",
            "29.3": "sha256-DpiU7C45krFNGD586sFkZdam7nPh0jRpXYDm0elHAUw=",
            "29.2": "sha256-uiCJWht/NKb/ql5Rw0ExbErrxMFEN3hjQITpn262f/k=",
            "29.1": "sha256-B1vWZq1B60BKkjv6+pCkr6IHSiyaqLnHfERF5hbo75s=",
            "29.0": "sha256-EJAnjNB1e3AsNrA+6t9KvTYCAnm7B7DfX4C9iW8+IDM=",
        },
    },
    "linux-s390_64": {
        "exec_compat": [
            "@platforms//os:linux",
            "@platforms//cpu:s390x",
        ],
        "integrity": {
            "31.0": "sha256-omxFoigT+yWCAywXzCe7xCp0JQZuoeigE0zvDJekc7g=",
            "30.2": "sha256-1ZBHfuHW4rgQhWt3InNC+yw5GTF4bIXtEqPMdB1Zl08=",
            "30.1": "sha256-orgjHBFZsAushwtu1OFs6dXSsImg4OkW/fPXCJNiC7Y=",
            "30.0": "sha256-eYcU19uRFfTgQr6G3R7quXNG31Qxof4QFhXJwcHhZM8=",
            "29.3": "sha256-Y3hX/bqwsTNL2ysIcz8L5JaF5pMBG2EEgJSRrGL71NU=",
            "29.2": "sha256-LwpVmdprgpMqCNQz+nkTux1oWIl8zTxrwyhvAYt2xOA=",
            "29.1": "sha256-J5fNVlyn/7/ALaVsygE7/0+X5oMkizuZ3PfUuxf27GE=",
            "29.0": "sha256-LhXZqwaFbCXKbeYi4RR4XZGHHb25HCwQPrYouH8m3Ew=",
        },
    },
    "linux-x86_32": {
        "exec_compat": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_32",
        ],
        "integrity": {
            "31.0": "sha256-rF81VWpm2MvczQNlgnXnII8jTiP6RSLcXjD8iKXWMe0=",
            "30.2": "sha256-wnMIeW55RbNqcd3rvR5R8lP2MjVdgwkTQktUwDx3MsY=",
            "30.1": "sha256-L5oRdIK9EripNAwhJ9iHefTdo7ZLTacJJ43EmaQ6c4Y=",
            "30.0": "sha256-OtMQ/NwrS/nzD1QrWbQDsrebqCss9DGb6E3poCZFrnY=",
            "29.3": "sha256-VGzx5pHOc/ZuKZzCLN1aF8YaEf5LbV34UHUHg4nx/Ck=",
            "29.2": "sha256-FU+NR+6YO8bxoa4tsUl+53E8Qt7vY1EXDxhmG/vNouw=",
            "29.1": "sha256-nd/EAbEqC4dHHg4POg0MKpByRj8EFDUUnpSfiiCCu+s=",
            "29.0": "sha256-tKyBCfKrSGLV5WuH4/cVMPug46YeyLnZQOKUdskGAQE=",
        },
    },
    "linux-x86_64": {
        "exec_compat": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        "integrity": {
            "31.0": "sha256-JOLtMgYLfJkNXrANZC/eBIadf3fG1EP2CTU/CXeZ3UI=",
            "30.2": "sha256-Mn6Tl8b7PqKlQlE6MiEzTG9296pSSn0lYRQrZ7MSoB8=",
            "30.1": "sha256-VTfhWrDA5hD4CVc5SNPsfW7zh6B5keHDYaKg6MrZg+U=",
            "30.0": "sha256-L7vBgYRj1+bZPBmo3qg55mPKX4V5pS73jHaIGIM1+mw=",
            "29.3": "sha256-PoZmIMW+J2ZPPS+i1la18+CbUVK0Lxvtv0J7Mz6QAho=",
            "29.2": "sha256-Uunn7OVcfjDn6LvSVLSyG0CKUwm8qCZ2PHEktpahMuk=",
            "29.1": "sha256-AMg/6XIthelsgblBsp8Xp0SzO0zmbg8YAJ/Yk33iLGA=",
            "29.0": "sha256-PFEGWvO5pgbZ4Yob9igUNzT/S55pcl1kWYV0MLp6eN8=",
        },
    },
    "osx-aarch_64": {
        "exec_compat": [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
        "integrity": {
            "31.0": "sha256-H75wqNZGh1+Rtv1XKU92MUUpKyyeE3SrCdbiEkr92VA=",
            "30.2": "sha256-knKMZQ9s8rbDeJGuBO9bwtS18yxfu9EB7aYj+Qu5X2M=",
            "30.1": "sha256-A0Z8/ZZ94SphQGt0c+gCBNOuOPMPgoVTGBhtaWI347k=",
            "30.0": "sha256-frW1HTe6xBC6cO+RxAT5Cx+ry4I3Ev9lZYLTSsyHynQ=",
            "29.3": "sha256-K4o0A80Jf5XzumVuFLdscytrJtfxgzMLEeNu8rwCh2U=",
            "29.2": "sha256-DhU6ONbaGVlMmA5/fNPqDd1SydoQaMA8DYUzNp+/6yA=",
            "29.1": "sha256-uP1ZdpJhmKfE6lxutL94lZ1frtJ7/GGCVMqhBD93BEU=",
            "29.0": "sha256-srWfA7AwyKdIYj1oKotbycwJnkvP0GuJZM6J7AZbMQM=",
        },
    },
    "osx-x86_64": {
        "exec_compat": [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
        "integrity": {
            "31.0": "sha256-A2DZttnj1mlYz2J02FFNpJ521HX9DXEhgdzH6eBW8sg=",
            "30.2": "sha256-ZWdcO7h0otXwyUHmG85hdQkL4l/kZvDsLUpvWXgzNiQ=",
            "30.1": "sha256-pK7v0vWczOWc+gGon+WK20C7kBD0Ot/KPE/uf9N+wsU=",
            "30.0": "sha256-lr86X77v1X19wMIKLHuz8iathLeeW1CThoJDIgF7lBc=",
            "29.3": "sha256-mniANtj5hU97A8MF30d3zw5U5bCB4lvxUlLah+DpCHU=",
            "29.2": "sha256-uivZg7XwbsONZjtgKISll96jmQpDgD1+FT7Y98VCaeE=",
            "29.1": "sha256-2wK0uG3k1MztPqmTQ0faKNyV5/OIY//EzjzCYoMCjaY=",
            "29.0": "sha256-56HP/ILiHapngzARRJxw3f8eujsRWTQ4fm6BQe+rCS8=",
        },
    },
    "win32": {
        "exec_compat": [
            "@platforms//os:windows",
            "@platforms//cpu:x86_32",
        ],
        "integrity": {
            "31.0": "sha256-7EmuJNtNqpTEDlr8wEfTCaYe4V+VRRrY5cehP9P9ubc=",
            "30.2": "sha256-XK6VrN8WkMCiTxh9uny6JdjuYAhcyVGn2SdM/gdx2RY=",
            "30.1": "sha256-nfRHsT+ijJqqwRdPWb30Al9KG9tuS2s/HOs+5o8HEQE=",
            "30.0": "sha256-g9c7ejnygRxhB/azkoWsWw8PRmNh1Gg96j796WNkMuY=",
            "29.3": "sha256-x8gCjBxNgBxTYCkg8shokgVAhr2WW2sjpLqV0hHcsdQ=",
            "29.2": "sha256-73CfcaUbOompsm3meCBc7zyV4h0IGLFn+/WwOackr9E=",
            "29.1": "sha256-EQXg+mRFnwsa9e5NWHfauGTy4Q2K6wRhjytpxsOm7QM=",
            "29.0": "sha256-154nzOTEAXRUERc8XraBFsPiBACxzEwt0stHeneUGP4=",
        },
    },
    "win64": {
        "exec_compat": [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        "integrity": {
            "31.0": "sha256-1+3uXQ1dZ4bJLnek9RHkaYpaqSLGOQttCMOnmTWmUbA=",
            "30.2": "sha256-EPNd93Iqad3o7pK0oWpOHMkc/Ogvu0o3G9BG3hOapKk=",
            "30.1": "sha256-d/TgIs6eiwh8uJP1P15DNzSULRJeTNL+y/gwrHdgBFw=",
            "30.0": "sha256-yEww2siMaLQKLkfFtsdi3B7Amu6zLB0efs8l153PnNo=",
            "29.3": "sha256-V+pZ6fVRrY1x/6qbXPvgyh9Ocglyodt+wtEqtEv/k4M=",
            "29.2": "sha256-Weph77JLnYohQXHiyj/sVcPxUX7/BnZWyHXYoc0Gzk8=",
            "29.1": "sha256-fqSCJYV//BIkWIwzXCsa+deKGK+dV8BSjMoxk+M26c4=",
            "29.0": "sha256-0DuSGYWLikyogGO3i/Clzec7UYCLkwxLZvBuhILDq+Y=",
        },
    },
}
