pipeline {
    agent any

    options {
        timestamps() 
        ansiColor('xterm') // Enable terminal colors
    }

    stages {

        stage ('Gradle test') {
            steps {
                sh './gradlew test'
            }
            post{
                always{
                    junit allowEmptyResults: true, keepLongStdio: true, testResults: '/Gradle/build/test-results/test/*xml'
                }
            }
        }

        stage('Test Jacoco'){
            steps{
                sh './gradlew clean test jacocoTestReport'
                jacoco()
            }
        }

        stage('Publish HTML') {
            steps {
                publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, includes: '**/jacoco/html/**', keepAll: false, reportDir: 'build/reports/jacoco/', reportFiles: 'index.html', reportName: 'jacocoReport'])
            }
        }

        stage('Build') {
            steps {
                sh '''docker-compose build
                      git tag 1.0.${BUILD_NUMBER}
                      docker tag ghcr.io/2000ghz/hello-springrest:latest ghcr.io/2000ghz/hello-springrest:1.0.${BUILD_NUMBER}
                      '''
                      sshagent(['github-credentials']) {
                        sh('git push git@github.com:2000ghz/hello-springrest.git --tags') // Push git tags
                      }
            }
        }

        stage('Push Image to GHCR') {
            steps{
                echo 'Logging into GitHub'
                withCredentials([string(credentialsId: 'Token-GitHub', variable: 'GITHUB_TOKEN')]) {
                    sh 'echo $GITHUB_TOKEN | docker login ghcr.io -u 2000ghz --password-stdin'
                    sh 'docker push ghcr.io/2000ghz/hello-springrest:1.0.${BUILD_NUMBER}' // Push image with tag 1.0.BuildNumber
                    sh 'docker push ghcr.io/2000ghz/hello-springrest:latest' // Push image with tag latest
                }
            }
        }

        stage('Deploy to EBS'){
            steps {
                withAWS(credentials: 'AWS Credentials') {
                    sh 'pwd'
                    sh '~/.ebcli-virtual-env/executables/eb deploy -v hello-springrest-dev'
                }
            }
        }

    }
}        
        