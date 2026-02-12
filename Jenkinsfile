pipeline {
    agent any
    tools {
        maven 'Maven 3.9.12'
        allure 'Allure 2.36.0'
    }

    stages {
        stage('Launch tests') {
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        sh "mvn test"
                    }
                }
            }
        }
        stage('Gen Allure report') {
            steps {
                allure includeProperties: false, jdk: '', resultPolicy: 'LEAVE_AS_IS', results: [[path: 'target/allure-results']]
            }
        }
    }
    post {
        always {
            echo "Fin d'éxécution"
        }
        success {
            echo "✅ Ca a chou - Tests passés → JAR généré avec succès"
        }
        aborted {
            echo "🚫 Tué, tué, tué"
        }
        failure {
            echo "❌ Gaing gaing gaing - Échec des tests ou du build"
        }
    }
}