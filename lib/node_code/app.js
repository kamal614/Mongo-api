const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const port = process.env.PORT || 3000;

// MongoDB connection
const uri = "mongodb+srv://kamal614:<PASSWORDHERE>@mgdbcluster.5cbsxor.mongodb.net/userDB?retryWrites=true&w=majority";
let client;

async function connectToMongoDB() {
    client = new MongoClient(uri, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        serverSelectionTimeoutMS: 5000,
        connectTimeoutMS: 5000
    });

    try {
        await client.connect();
        console.log('Connected to MongoDB successfully!');
    } catch (err) {
        console.error('Could not connect to MongoDB:', err);
    }
}

connectToMongoDB();

const db = () => client.db('userDB');
const collection = () => db().collection('userCollection');

app.get('/', (req, res) => {
    res.send('Welcome to the MongoDB API!');
});

app.get('/data', async (req, res) => {
    try {
        const documents = await collection().find({}, { projection: { _id: 0 } }).toArray();
        res.status(200).json(documents);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

app.get('/data/:id', async (req, res) => {
    try {
        const id = req.params.id;
        const document = await collection().findOne({ id }, { projection: { _id: 0 } });
        if (document) {
            res.status(200).json(document);
        } else {
            res.status(404).json({ error: 'Data not found' });
        }
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
