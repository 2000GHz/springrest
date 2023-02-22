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
                      docker tag ghcr.io/2000ghz/hello-springrest/hello-springrest:latest ghcr.io/2000ghz/hello-springrest/hello-springrest:1.0.${BUILD_NUMBER}
                      '''
                      sshagent(['github-credentials']) {
                        sh('git push git@github.com:2000ghz/hello-springrest.git --tags') // Push git tags
                      }
            }
        }

        stage('Login') {
            steps{
                echo 'Logging into GitHub'
                withCredentials([string(credentialsId: 'Token-GitHub', variable: 'GITHUB_TOKEN')]) {
                    sh 'echo $GITHUB_TOKEN | docker login ghcr.io -u 2000ghz --password-stdin'
                    sh 'docker-compose push ghcr.io/2000ghz/hello-springrest/hello-springrest:1.0.${BUILD_NUMBER}' // Push image with tag 1.0.BuildNumber
                    sh 'docker-compose push ghcr.io/2000ghz/hello-springrest/hello-springrest:latest' // Push image with tag latest
                }
            }
        }
    }
}        
        