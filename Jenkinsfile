pipeline {
    agent any

    options {
        timestamps() 
        ansiColor('xterm') // Enable terminal colors
    }

    stages {

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
                    sh '~/.ebcli-virtual-env/executables/eb deploy hello-springrest-dev'
                }
            }
        }   
    }
}        
        