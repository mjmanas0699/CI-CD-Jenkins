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

// #-------------
job('Build and Push the Image To ECR') {
    steps {
        shell(''' #/bin/bash
                pwd
                repo_name=$(aws ecr describe-repositories --repository-names=test-cli --query='repositories[].repositoryUri' --output text)
                cd ~/tasks/ && last_commit=$(git rev-parse HEAD)
                sudo docker build -t $repo_name:$last_commit -f ~/tasks/Dockerfile .
                aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin $(echo $repo_name | awk -F / '{print $1}')
                sudo docker push $repo_name:$last_commit
                 ''')
        triggers {
            upstream('Create Repository', 'SUCCESS')
        }
    }
}
