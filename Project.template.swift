import ProjectDescription

let projectSettings: Settings = .settings(
    configurations: [
        .debug(name: "Debug", xcconfig: xcconfig_loc("project")),
        .release(name: "Release", xcconfig: xcconfig_loc("project"))
    ]
)

let targetSettings: Settings = .settings(
    configurations: [
        .debug(name: "Debug", xcconfig: xcconfig_loc("target")),
        .release(name: "Release", xcconfig: xcconfig_loc("target")),
    ]
)

let project = Project(
    name: "noTunez",
    organizationName: "",
    packages: [
      .remote(
            url: "https://github.com/sindresorhus/LaunchAtLogin.git",
            requirement: .exact("5.0.0")
      )
    ],
    settings: projectSettings,
    targets: [
        Target(
            name: "noTunez",
            platform: .macOS,
            product: .app,
            bundleId: "xyz.kondor.noTunez",
            infoPlist: "../sources/Info.plist",
            sources: [
              sources(glob: "*.swift"),
            ],
            resources: [
              sources("Base.lproj/**"),
              sources("Assets.xcassets")
            ],
            headers: .none,
            entitlements: nil,
            scripts: [
                .post(script: """
                    ${BUILT_PRODUCTS_DIR}/LaunchAtLogin_LaunchAtLogin.bundle/Contents/Resources/copy-helper-swiftpm.sh
                """, name: "Copy LaL Helper", basedOnDependencyAnalysis: false)
            ],
            dependencies: [
                .package(product: "LaunchAtLogin")
            ],
            settings: targetSettings
        ) 
    ]
)

func xcconfig_loc(_ name: String) -> Path {
    Path("../config/\(name).xcconfig")
}

func sources(_ patternOrPath: String) -> ResourceFileElement {
    "../sources/\(patternOrPath)"
}

func sources(glob: String) -> SourceFileGlob {
    SourceFileGlob("../sources/\(glob)")
}
