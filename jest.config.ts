import type { Config } from "jest";

const config: Config = {
  projects: [
    {
      displayName: "unit",
      testMatch: ["<rootDir>/**/?(*.)unit.test.ts"],
      preset: "ts-jest",
      testEnvironment: "node",
      rootDir: ".",
      reporters: [
        "default",
        [
          "jest-junit",
          {
            outputDirectory: "build/test-results",
            outputName: "junit-unit.xml"
          }
        ]
      ]
    },
    {
      displayName: "integration",
      testMatch: ["<rootDir>/**/?(*.)integration.test.ts"],
      preset: "ts-jest",
      testEnvironment: "node",
      rootDir: ".",
      reporters: [
        "default",
        [
          "jest-junit",
          {
            outputDirectory: "build/test-results",
            outputName: "junit-integration.xml"
          }
        ]
      ]
    }
  ]
};

export default config;

