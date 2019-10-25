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
        lock('refs/remotes/origin/master') {
          sh '/usr/local/bin/pod install --repo-update --project-directory=Example/'
        }
      }
    }
    stage('Build') {
      steps {
        sh 'xcodebuild -workspace Example/Gini.xcworkspace -scheme "Example" -destination \'platform=iOS Simulator,name=iPhone XS\''
      }
    }
    stage('Unit tests') {
      steps {
        sh 'xcodebuild test -workspace Example/Gini.xcworkspace -scheme "Gini-Unit-Tests" -destination \'platform=iOS Simulator,name=iPhone XS\''
      }
    }
    stage('Documentation') {
      when {
        branch 'master'
        expression {
            def tag = sh(returnStdout: true, script: 'git tag --contains $(git rev-parse HEAD)').trim()
            return !tag.isEmpty()
        }
      }
      steps {
        sh 'Documentation/scripts/deploy-documentation.sh $GIT_USR $GIT_PSW'
      }
    }
    stage('Pod release') {
      when {
        branch 'master'
        expression {
            def tag = sh(returnStdout: true, script: 'git tag --contains $(git rev-parse HEAD)').trim()
            return !tag.isEmpty()
        }
      }
      steps {
        sh '/usr/local/bin/pod trunk push Gini.podspec --allow-warnings'
      }
    }
  }
}
