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
        stage("Down running container") {
            steps {
                script {
                    sh 'docker compose down'
                    sh 'docker ps'
                }
            }
        }
        stage("Clear all running docker containers") {
            steps {
                script {
                    try {
                        sh 'docker system prune -a -f'
                        sh 'docker stop $(docker ps -a -q)'
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
            environment {
                DB_HOST = credentials("laravel-db-host")
                DB_DATABASE = credentials("laravel-database")
                DB_USERNAME = credentials("laravel-db-user")
                DB_PASSWORD = credentials("laravel-db-password")
            }          
            steps {
                sh 'cp ./src/.env.example ./src/.env'
                sh 'echo DB_HOST=${DB_HOST} >> .env'
                sh 'echo DB_USERNAME=${DB_USERNAME} >> .env'
                sh 'echo DB_DATABASE=${DB_DATABASE} >> .env'
                sh 'echo DB_PASSWORD=${DB_PASSWORD} >> .env'
                sh 'docker compose run --rm artisan key:generate'
                sh 'docker compose run --rm artisan cache:clear'
                sh 'docker compose run --rm artisan config:clear'
                sh 'docker compose run --rm artisan migrate'
                sh 'docker compose run --rm artisan storage:link'
            }
        }              
        stage("Run Tests") {
            steps {
                sh 'docker compose run --rm artisan test'
            }
        }

        stage('Build docker image'){
            steps{
                script{
                    sh 'docker compose build --no-cache'
                }
            }
        }

        stage('Push image to Hub'){
            steps{
                script{
                    withCredentials([string(credentialsId: 'dockerhub-pwd', variable: 'dockerhubpwd')]) {
                        sh 'docker login -u issaadi -p ${dockerhubpwd}'
                    }
                    sh 'docker compose push'
                }
            }
        }
    }

    post {
        success {
            environment {
                DB_HOST = credentials("laravel-db-host")
                DB_DATABASE = credentials("laravel-database")
                DB_USERNAME = credentials("laravel-db-user")
                DB_PASSWORD = credentials("laravel-db-password")
                SSH_PRIVATE_KEY = credentials('aws-ec2')
            }       
            script {
                sh 'ssh -o StrictHostKeyChecking=no -i ${SSH_PRIVATE_KEY} ec2-user@52.2.192.244 docker compose down 
                && cd photogalleryaws
                && docker pull issaadi/photogallery-php8.1.5:latest 
                && docker pull issaadi/photogallery-artisan:latest
                && docker compose -f docker-compose.prod.yml  up -d --force-recreate
                && docker compose run --rm composer install
                && cp ./src/.env.example ./src/.env
                && echo DB_HOST=${DB_HOST} >> .env
                && echo DB_USERNAME=${DB_USERNAME} >> .env
                && echo DB_DATABASE=${DB_DATABASE} >> .env
                && echo DB_PASSWORD=${DB_PASSWORD} >> .env
                && docker compose run --rm artisan key:generate
                && docker compose run --rm artisan cache:clear
                && docker compose run --rm artisan config:clear
                && docker compose run --rm artisan migrate
                && docker compose run --rm artisan storage:link'
            }
        }
        failure {
            echo "I FAILED"
        }
        always {
            sh 'docker compose down'
            sh 'docker compose ps'
        }
    }
}

