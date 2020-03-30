#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  triggers {
    cron(getDailyCronString())
  }

  stages {
    stage('Validate') {
      parallel {
        stage('Changelog') {
          steps { sh './bin/parse-changelog.sh' }
        }
      }
    }

    stage('Build Docker image') {
      steps {
        sh './build.sh'
      }
    }

    stage('Scan Docker image') {
      steps {
        scanAndReport("conjur-service-broker", "NONE")
      }
    }

    stage('Run tests') {
      steps {
        sh 'summon ./test.sh'

        junit 'features/reports/**/*.xml, spec/reports/*.xml'
      }
    }

    stage('Push Docker image') {
      steps {
        sh './push-image.sh'
      }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult)
    }
  }
}
