const AWS = require("aws-sdk");
const axios = require('axios');


const region = process.env.AWS_REGION;
const accountId = process.env.AWS_ACCOUNT_ID
AWS.config.update({ region });


const sqsOpenTelemetryExample = () => {
  return new Promise((resolve, reject) => {
    const sqs = new AWS.SQS({apiVersion: '2012-11-05'});
    const queueName = process.env.SQS_QUEUE_NAME;
    const queueUrl = `https://sqs.${region}.amazonaws.com/${accountId}/${queueName}`

    sqs.sendMessage({
      QueueUrl: queueUrl,
      DelaySeconds: 10,
      MessageAttributes: {
        Hello: {
          DataType: 'String',
          StringValue: 'World'
        }
      },
      MessageBody: "Foo Bar"
    }, (error, response) => {
      console.log(`SQS Response: `, response, error)
      error ?
        resolve({ sqs: { error } }) :
        resolve({ sqs: { response } })
    })
  })
}


const snsOpenTelemetryExample = () => {
  return new Promise((resolve, reject) => {
    const sns = new AWS.SNS({ apiVersion: '2010-03-31' });
    const topicName = process.env.SNS_TOPIC_NAME;
    const topicArn = `arn:aws:sns:${region}:${accountId}:${topicName}`

    sns.publish({
      Message: JSON.stringify({
        default: 'Hello World Message',
      }),
      TopicArn: topicArn,
    }, (error, response) => {
      console.log(`SNS Response: `, response, error)
      error ?
        resolve({ sns: { error } }) :
        resolve({ sns: { response } })
    })
  })
}

const s3OpenTelemetryExample = () => {
  return new Promise((resolve, reject) => {
    const s3 = new AWS.S3();
    const bucketName = process.env.S3_BUCKET_NAME;

    s3.putObject({
      Bucket: `${bucketName}`,
      Key: 'filename',
      Body: 'Random body content',
    }, (error, response) => {
      console.log(`S3 Response: `, response, error)
      error ?
        resolve({ s3: { error } }) :
        resolve({ s3: { response } })
    })
  })
}


const lambdaOpenTelemetryExample = () => {
  return new Promise((resolve, reject) => {
    const lambda = new AWS.Lambda();
    const env = process.env.DEPLOYMENT_ENV;
    const service = process.env.SERVICE;

    lambda.invoke({
      FunctionName: `${service}-${env}-ExampleReceiverOpenTelemetry`,
      InvocationType: 'RequestResponse',
      LogType: 'Tail',
      Payload: JSON.stringify({
        name: 'hello-world',
        age: 100,
      }),
    }, (error, response) => {
      console.log(`Lambda Response: `, response, error)
      error ?
        resolve({ lambda: { error } }) :
        resolve({ lambda: { response } })
    })
  })
}

const stepFunctionOpenTelemetryExample = () => {
  return new Promise((resolve, reject) => {
    const stepFunctions = new AWS.StepFunctions();
    const stateMachineName = process.env.STATE_MACHINE_NAME;
    const stateMachineArn = `arn:aws:states:${region}:${accountId}:stateMachine:${stateMachineName}`;

    stepFunctions.startExecution({
      stateMachineArn,
      input: JSON.stringify({ hello: 'world' }),
    }, (error, response) => {
      console.log(`State Machine Response: `, response, error)
      error ?
        resolve({ stateMachine: { error } }) :
        resolve({ stateMachine: { response } })
    })
  })
}

const httpOpenTelemetryExample = () => {
  return new Promise((resolve, reject) => {
    axios.get(`https://www.google.com`)
      .then((response) => resolve({ http: { response } }))
      .catch((error) => resolve({ http: { error } }))
  })
}


module.exports.main = (event, context, callback) => {
  Promise.all([
    sqsOpenTelemetryExample(),
    snsOpenTelemetryExample(),
    s3OpenTelemetryExample(),
    lambdaOpenTelemetryExample(),
    stepFunctionOpenTelemetryExample(),
    httpOpenTelemetryExample(),
  ]).then((body) => {
    callback(null, {
      statusCode: 200,
      body: JSON.stringify({
        status: 'success',
        parts: body
      })
    })
  }).catch((body) => {
    callback(null, {
      statusCode: 400,
      body: JSON.stringify({
        status: 'failure',
        parts: body
      })
    })
  })
};


module.exports.receiver = (event, context, callback) => {
  callback(null, {
    statusCode: 200,
    body: JSON.stringify({
      status: 'success'
    })
  })
};

