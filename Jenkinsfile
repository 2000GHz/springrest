pipeline {
    agent any

    options {
        timestamps() 
        ansiColor('xterm') // Enable terminal colors
    }

    stages {

         stage('Trivy Scan') {
            steps {
                sh 'mkdir -p reports'
                sh '/home/linuxbrew/.linuxbrew/bin/trivy fs --vuln-type os,library,secret --format json -o trivyscanresults-filesystem.json .'
                sh '/home/linuxbrew/.linuxbrew/bin/trivy image --vuln-type os,library,secret --format json -o trivyscanresults-image.json ghcr.io/2000ghz/springrest:latest'
                recordIssues(tools: [trivy(pattern: 'trivyscanresults-filesystem.json, trivyscanresults-image.json')])
            }
        }

        stage ('Gradle test') {
            steps {
                sh './gradlew test'
            }
            post{
                always{
                    junit allowEmptyResults: true, keepLongStdio: true, testResults: '/build/test-results/test/*xml'
                }
            }
        }

        stage('Test Jacoco'){
            steps{
                sh './gradlew clean test jacocoTestReport'
                jacoco()
            }
        }

       stage('PMD Test') {
            steps {
                sh './gradlew pmdTest'
            }
            post {
                always {
                    recordIssues(
                        enabledForFailure: true, aggregatingResults: true,
                        tool: pmdParser(pattern: 'build/reports/pmd/test.xml')
                    )
                }
            }
        }

        stage('Build') {
            steps {
                sh '''docker-compose build
                      git tag 1.0.${BUILD_NUMBER}
                      docker tag ghcr.io/2000ghz/springrest:latest ghcr.io/2000ghz/springrest:1.0.${BUILD_NUMBER}
                      '''
                      sshagent(['github-credentials']) {
                        sh('git push git@github.com:2000ghz/springrest.git --tags') // Push git tags
                      }
            }
        }

        stage('Push Image to GHCR') {
            steps{
                echo 'Logging into GitHub'
                withCredentials([string(credentialsId: 'Token-GitHub', variable: 'GITHUB_TOKEN')]) {
                    sh 'echo $GITHUB_TOKEN | docker login ghcr.io -u 2000ghz --password-stdin'
                    sh 'docker push ghcr.io/2000ghz/springrest:1.0.${BUILD_NUMBER}' // Push image with tag 1.0.BuildNumber
                    sh 'docker push ghcr.io/2000ghz/springrest:latest' // Push image with tag latest
                }
            }
        }

        stage('Deploy to EBS'){
            steps {
                withAWS(credentials: 'AWS Credentials') {
                    sh '~/.ebcli-virtual-env/executables/eb deploy springrest-dev'     
                }
            }
        }
    }
}        
        