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
    stage('Build') {
      steps { sh './build.sh' }
    }

    stage('Test And Check') {
      parallel {
        stage('Changelog') {
          steps { sh './bin/parse-changelog.sh' }
        }

        stage('Fixable Docker Image Issues') {
          steps { scanAndReport("conjur-service-broker", "HIGH", false) }
        }

        stage('All Docker Image Issues') {
          steps { scanAndReport("conjur-service-broker", "NONE", true) }
        }

        stage('Tests') {
          steps {
            sh 'summon ./test.sh'

            junit 'features/reports/**/*.xml, spec/reports/*.xml'
          }

          post {
            success {
              script {
                if (env.BRANCH_NAME == 'master') {
                  archiveArtifacts artifacts: '*.zip', fingerprint: true
                }
              }
            }
          }
        }
      }
    }

    stage('Push Docker Image') {
      steps { sh './push-image.sh' }
    }
  }

  post {
    always { cleanupAndNotify(currentBuild.currentResult) }
  }
}
