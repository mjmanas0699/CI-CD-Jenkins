//---------JOB1---
job('Repo-Clonning') {
    scm {
        github('mjmanas0699/dotsquare', 'main')
    }
    steps {
        shell (
            '''
            mkdir -p  ~/tasks
            sudo cp -rvf * ~/tasks/ 
            sudo cp -r .git   ~/tasks/
            '''
        )
        triggers {
            upstream('seed job', 'SUCCESS')
        }
    }
}
//-----------JOB2---

job('Create Repository') {
    steps {
        shell(''' 
echo '#/bin/bash
aws ecr describe-repositories --repository-name=test-cli
a=$?
if [[ $a -eq 0 ]]; 
then
    echo "Repo present"
else
    aws ecr create-repository --repository-name test-cli
    echo "Repo Creation Done"
fi'  > test.sh
bash test.sh 
''')

        triggers {
            upstream('Repo-Clonning', 'SUCCESS')
        }
    }
}

// #-----JOB3--------
job('Build and Push the Image To ECR') {
    steps {
        shell(''' #/bin/bash
                pwd
                export repo_name=$(aws ecr describe-repositories --repository-names=test-cli --query='repositories[].repositoryUri' --output text)
                cd ~/tasks/ && export last_commit=$(git rev-parse HEAD)
                sudo docker build -t $repo_name:$last_commit -f ~/tasks/Dockerfile .
                aws ecr get-login-password --region ap-south-1 | sudo docker login --username AWS --password-stdin $(echo $repo_name | awk -F / '{print $1}')
                sudo docker push $repo_name:$last_commit
                 ''')
        triggers {
            upstream('Create Repository', 'SUCCESS')
        }
    }
}

//----JOB4--
job('Create EKS Cluster If Not Exists') {
    steps {
        shell('''
echo "#/bin/bash
aws eks describe-cluster --name test-cluster
a=$?
if [[ $a -eq 0 ]]; 
then
    echo "Cluster Present"
else
    eksctl create cluster -f ~/tasks/config.yaml
    echo "Cluster Creation Done"
fi" > test.sh  
        ''')
        triggers {
            upstream('Build and Push the Image To ECR', 'SUCCESS')
        }
    }
}

//-----JOB5---
job('Add Kubeconfig') {
    steps {
        shell(''' aws eks --region ap-south-1 update-kubeconfig --name test-cluster ''')
        triggers {
            upstream('Create EKS Cluster If Not Exists', 'SUCCESS')
        }
    }
}

//-------JOB6---
job('Deploy to Cluster') {
    steps {
        shell('''
                export repo_name=$(aws ecr describe-repositories --repository-names=test-cli --query='repositories[].repositoryUri' --output text)
                cd ~/tasks/ && export last_commit=$(git rev-parse HEAD)
                sed -i 's|image_name|'${repo_name}:${last_commit}'|g' ~/tasks/kube/deployment.yaml
                kubectl apply -f ~/tasks/kube/
         ''')
        triggers {
            upstream('Add Kubeconfig', 'SUCCESS')
        }
    }
}

