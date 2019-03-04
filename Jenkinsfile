pipeline {
  agent any
  environment {
    GIT = credentials('github')
  }
  stages {
    stage('Prerequisites') {
      environment {
        GEONOSIS_USER_PASSWORD = credentials('GeonosisUserPassword')
        CLIENT_ID = credentials('VisionClientID')
        CLIENT_PASSWORD = credentials('VisionClientPassword')
      }
      steps {
        sh 'security unlock-keychain -p ${GEONOSIS_USER_PASSWORD} login.keychain'
        sh 'scripts/create_keys_file.sh ${CLIENT_ID} ${CLIENT_PASSWORD}'
        lock('refs/remotes/origin/master') {
          sh '/usr/local/bin/pod install --repo-update --project-directory=Example/'
        }
      }
    }
    stage('Build') {
      steps {
        sh 'xcodebuild -workspace Example.xcworkspace -scheme "Example" -destination \'platform=iOS Simulator,name=iPhone XS\''
      }
    }
    stage('Unit tests') {
      steps {
        sh 'xcodebuild test -workspace Example.xcworkspace -scheme "Gini-Unit-Tests" -destination \'platform=iOS Simulator,name=iPhone XS\''
      }
    }
  }
}
