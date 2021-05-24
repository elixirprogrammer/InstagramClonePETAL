"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const node_fetch_1 = require("node-fetch");
var node_fetch_2 = require("node-fetch");
exports.Response = node_fetch_2.Response;
class BuildpackRegistryApi {
    static url() {
        if (process.env.HEROKU_BUILDPACK_REGISTRY_URL === undefined) {
            return 'https://buildpack-registry.heroku.com';
        }
        else {
            return process.env.HEROKU_BUILDPACK_REGISTRY_URL;
        }
    }
    static create() {
        return new BuildpackRegistryApi();
    }
    headers(options = {}) {
        let defaultHeaders = {
            Accept: 'application/vnd.heroku+json; version=3.buildpack-registry',
            'Content-Type': 'application/json'
        };
        if (options.token !== undefined) {
            defaultHeaders.Authorization = `Bearer ${options.token}`;
        }
        if (options.secondFactor) {
            defaultHeaders['Heroku-Two-Factor-Code'] = options.secondFactor;
        }
        if (process.env.HEROKU_HEADERS) {
            let herokuHeaders = JSON.parse(process.env.HEROKU_HEADERS);
            return new node_fetch_1.Headers(Object.assign({}, defaultHeaders, { herokuHeaders }));
        }
        else {
            return new node_fetch_1.Headers(defaultHeaders);
        }
    }
    async post(path, body, headers) {
        let options = {
            method: 'POST',
            headers: headers ? headers : this.headers(),
        };
        if (body) {
            options.body = JSON.stringify(body);
        }
        return node_fetch_1.default(`${BuildpackRegistryApi.url()}${path}`, options);
    }
    async get(path) {
        return node_fetch_1.default(`${BuildpackRegistryApi.url()}${path}`, {
            headers: this.headers()
        });
    }
}
exports.BuildpackRegistryApi = BuildpackRegistryApi;
