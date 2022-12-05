pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }
	    stage("Verify tooling") {
            steps {
                sh '''
                    whoami
                    docker info
                    docker version
                    docker compose version
                '''
            }
        }
        stage("Clear all running docker containers") {
            steps {
                script {
                    try {
                        sh 'docker system prune -a -y'
                        sh 'docker rm -f $(docker ps -a -q)'
                    } catch (Exception e) {
                        echo 'No running container to clear up...'
                    }
                }
            }
        }
        stage("Start Docker") {
            steps {
                sh 'make up'
                sh 'docker compose ps'
            }
        }
        stage("Run Composer Install") {
            steps {
                sh 'docker compose run --rm composer install'
            }
        }
        stage("Run laravel artisans") {            
            steps {
                sh 'cp ./src/.env.example ./src/.env'
                sh 'docker compose run --rm artisan key:generate'
                sh 'cat ./src/.env'
                sh 'docker compose run --rm artisan cache:clear'
                sh 'docker compose run --rm artisan config:clear'
                sh 'cat ./src/.env'
                sh 'docker compose run --rm artisan migrate'
                sh 'docker compose run --rm artisan storage:link'
            }
        }              
        stage("Run Tests") {
            steps {
                sh 'docker compose run --rm artisan test'
            }
        }

        stage("Publish images") {
            steps {
                sh 'echo "$REGISTRY_PASSWORD" | docker login --username "$REGISTRY_USER" --password-stdin'
                sh 'docker '
            }
        }

        stage('Build docker image'){
            steps{
                script{
                    sh 'docker build -t issaadi/photogallery .'
                }
            }
        }

        stage('Push image to Hub'){
            steps{
                script{
                    withCredentials([string(credentialsId: 'dockerhub-pwd', variable: 'dockerhubpwd')]) {
                        sh 'docker login -u issaadi -p ${dockerhubpwd}'
                    }
                    sh 'docker push issaadi/photogallery'
                }
            }
        }
    }
}

