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
    stage('Build Artifacts') {
      steps { sh './build.sh' }
    }

    stage('Test And Check') {
      parallel {
        stage('Changelog') {
          steps { sh './bin/parse-changelog.sh' }
        }

        stage('Docker Fixable Image Issues') {
          steps { scanAndReport("conjur-service-broker", "HIGH", false) }
        }

        stage('Docker Image Issues') {
          steps { scanAndReport("conjur-service-broker", "NONE", true) }
        }

        stage('Run tests') {
          steps {
            sh 'ls -la .'
            // sh 'summon ./test.sh'

            // junit 'features/reports/**/*.xml, spec/reports/*.xml'
          }

          post {
            success {
              script {
                archiveArtifacts artifacts: '*.zip', fingerprint: true
              }
            }
          }
        }
      }
    }

    stage('Push Docker image') {
      steps { sh './push-image.sh' }
    }
  }

  post {
    always { cleanupAndNotify(currentBuild.currentResult) }
  }
}
