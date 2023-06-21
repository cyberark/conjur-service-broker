#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
    lock resource: "tas-infra"
  }

  triggers {
    cron(getDailyCronString())
  }

  stages {
    stage('Grant IP Access') {
      steps {
        // Grant access to this Jenkins agent's IP to AWS security groups
        grantIPAccess()
      }
    }
    stage('Build') {
      steps { sh './dev/build' }
    }

    stage('Vulnerability Scans') {
      parallel {
        stage('Fixable Docker Image Issues') {
          steps { scanAndReport("conjur-service-broker", "HIGH", false) }
        }
        stage('All Docker Image Issues') {
          steps { scanAndReport("conjur-service-broker", "NONE", true) }
        }
      }
    }

    stage('Unit and Integration Testing') {
      parallel {
        stage('Changelog') {
          steps { parseChangelog() }
        }

        stage('Unit Tests') {
          steps {
            sh './dev/test_unit'
          }
        }

        stage('Integration Tests') {
          steps {
            sh './dev/test_integration'
            junit 'features/reports/**/*.xml, spec/reports/*.xml'
          }

          post {
            success {
              script {
                if (env.BRANCH_NAME == 'main') {
                  archiveArtifacts artifacts: '*.zip', fingerprint: true
                }
              }
            }
          }
        }
      }
    }

    // The End-to-End test needs to be run separately from the integration
    // tests because both use the default docker-compose network, and
    // both cause this network to be deleted when they clean up with
    // 'docker-compose down ...'.
    stage('End-to-End Testing') {
      steps {
        allocateTas('isv_ci_tas_srt_2_13')
        sh 'cd dev && summon ./test_e2e'
        junit 'features/reports/**/*.xml, spec/reports/*.xml'
      }

      post {
        always {
          destroyTas()
        }
        success {
          script {
            if (env.BRANCH_NAME == 'main') {
              archiveArtifacts artifacts: '*.zip', fingerprint: true
            }
          }
        }
      }
    }

    stage('Push Docker Image') {
      steps { sh './dev/push-image' }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult)
    }
  }
}
