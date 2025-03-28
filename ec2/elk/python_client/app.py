import aiohttp
import datetime
import os
from fastapi import FastAPI
from fastapi.encoders import jsonable_encoder
from elasticsearch import AsyncElasticsearch, NotFoundError
from elasticsearch.helpers import async_streaming_bulk
from elasticapm.contrib.starlette import ElasticAPM, make_apm_client

client = AsyncElasticsearch(os.environ["ELASTICSEARCH_HOSTS"])

# Створення FastAPI додатку
app = FastAPI()

@app.on_event("shutdown")
async def app_shutdown():
    await client.close()


async def download_games_db():
    async with aiohttp.ClientSession() as http:
        url = "https://cdn.thegamesdb.net/json/database-latest.json"
        resp = await http.request("GET", url)
        for game in (await resp.json())["data"]["games"][:100]:
            yield game


@app.get("/")
async def index():
    return await client.cluster.health()


@app.get("/ingest")
async def ingest():
    if not (await client.indices.exists(index="games")):
        await client.indices.create(index="games")

    async for _ in async_streaming_bulk(
        client=client, index="games", actions=download_games_db()
    ):
        pass

    return {"status": "ok"}


@app.get("/search/{query}")
async def search(query):
    return await client.search(
        index="games", body={"query": {"multi_match": {"query": query}}}
    )


@app.get("/delete")
async def delete():
    return await client.delete_by_query(index="games", body={"query": {"match_all": {}}})


@app.get("/delete/{id}")
async def delete_id(id):
    try:
        return await client.delete(index="games", id=id)
    except NotFoundError as e:
        return e.info, 404


@app.get("/update")
async def update():
    response = []
    docs = await client.search(
        index="games", body={"query": {"multi_match": {"query": ""}}}
    )
    now = datetime.datetime.utcnow()
    for doc in docs["hits"]["hits"]:
        response.append(
            await client.update(
                index="games", id=doc["_id"], body={"doc": {"modified": now}}
            )
        )

    return jsonable_encoder(response)


@app.get("/error")
async def error():
    try:
        await client.delete(index="games", id="somerandomid")
    except NotFoundError as e:
        return e.info


@app.get("/doc/{id}")
async def get_doc(id):
    return await client.get(index="games", id=id)
