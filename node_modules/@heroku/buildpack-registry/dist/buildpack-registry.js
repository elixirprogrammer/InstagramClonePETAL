"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const true_myth_1 = require("true-myth");
const buildpack_registry_api_1 = require("./buildpack-registry-api");
const BUILDPACK_FORMATTING_MESSAGE = "To specify a buildpack, please format it like the following: namespace/name (e.g. heroku/ruby). Also names can only contain letters, numbers, '_', and '-'.";
class BuildpackRegistry {
    static isValidBuildpackSlug(buildpack) {
        let nameParts = buildpack.split('/');
        if (nameParts.length === 2 && nameParts[0].length > 0 && nameParts[1].length > 0 && /^[a-z0-9][a-z0-9_\-]*$/i.exec(nameParts[1])) {
            return true_myth_1.Result.ok(true);
        }
        else {
            return true_myth_1.Result.err(BUILDPACK_FORMATTING_MESSAGE);
        }
    }
    constructor() {
        this.api = buildpack_registry_api_1.BuildpackRegistryApi.create();
    }
    async requiresTwoFactor(buildpack) {
        let path = `/buildpacks/${encodeURIComponent(buildpack)}`;
        let response = await this.api.get(path);
        if (response.status === 200) {
            let body = await response.json();
            return true_myth_1.Result.ok(body.two_factor_authentication);
        }
        else {
            return true_myth_1.Result.err({
                status: response.status,
                path,
                description: await response.text()
            });
        }
    }
    async publish(buildpack, ref, token, secondFactor) {
        let options = { token };
        if (secondFactor !== undefined) {
            options.secondFactor = secondFactor;
        }
        let path = `/buildpacks/${encodeURIComponent(buildpack)}/revisions`;
        let response = await this.api.post(path, { ref }, this.api.headers(options));
        if (response.status === 200) {
            return true_myth_1.Result.ok(await response.json());
        }
        else {
            return true_myth_1.Result.err({
                status: response.status,
                path,
                description: await response.text()
            });
        }
    }
    async rollback(buildpack, token, secondFactor) {
        let options = { token };
        if (secondFactor !== undefined) {
            options.secondFactor = secondFactor;
        }
        let path = `/buildpacks/${encodeURIComponent(buildpack)}/actions/rollback`;
        let response = await this.api.post(path, undefined, this.api.headers(options));
        if (response.status === 200) {
            return true_myth_1.Result.ok(await response.json());
        }
        else {
            return true_myth_1.Result.err({
                status: response.status,
                path,
                description: await response.text(),
            });
        }
    }
    async search(namespace, name, description) {
        let queryParams = [];
        let queryString = '';
        if (namespace) {
            queryParams = namespace.split(',')
                .map(namespace => `in[namespace][]=${namespace}`);
        }
        if (name) {
            queryParams = queryParams.concat(name.split(',')
                .map(name => `in[name][]=${name}`));
        }
        if (description) {
            queryParams = queryParams.concat(`like[description]=${encodeURIComponent(description)}`);
        }
        if (queryParams.length > 0) {
            queryString = `?${queryParams.join('&')}`;
        }
        let path = `/buildpacks${queryString}`;
        let response = await this.api.get(path);
        if (response.status === 200) {
            return true_myth_1.Result.ok(await response.json());
        }
        else {
            return true_myth_1.Result.err({
                status: response.status,
                path,
                description: await response.text(),
            });
        }
    }
    async info(buildpack) {
        let path = `/buildpacks/${encodeURIComponent(buildpack)}`;
        let response = await this.api.get(path);
        if (response.status !== 200) {
            return true_myth_1.Result.err({
                status: response.status,
                path,
                description: await response.text(),
            });
        }
        let bp_body = await response.json();
        let result = await this.listVersions(buildpack);
        if (result.isErr()) {
            return true_myth_1.Result.err(result.unsafelyUnwrapErr());
        }
        let revisions = result.unsafelyUnwrap();
        let revision = revisions.sort((a, b) => {
            return a.release > b.release ? -1 : 1;
        })[0];
        path = `/buildpacks/${encodeURIComponent(buildpack)}/readme`;
        response = await this.api.get(path);
        if (response.status !== 200) {
            return true_myth_1.Result.err({
                status: response.status,
                path,
                description: await response.text()
            });
        }
        let readme = await response.json();
        let data = {
            description: bp_body.description,
            category: bp_body.category,
            license: revision.license
        };
        if (bp_body.support.method === 'email') {
            data.support = bp_body.support.address.replace('mailto:', '');
        }
        else if (bp_body.support.method === 'github') {
            data.support = `https://github.com/${bp_body.source.owner}/${bp_body.source.repo}/issues`;
        }
        else if (bp_body.support.method === 'unsupported') {
            data.support = 'Unsupported by author';
        }
        else {
            data.support = bp_body.support.address;
        }
        if (bp_body.source.type === 'github') {
            data.source = `https://github.com/${bp_body.source.owner}/${bp_body.source.repo}`;
        }
        if (readme.content) {
            data.readme = `\n${Buffer.from(readme.content, readme.encoding).toString()}`;
        }
        return true_myth_1.Result.ok(data);
    }
    async archive(buildpack, token, secondFactor) {
        let options = { token };
        if (secondFactor !== undefined) {
            options.secondFactor = secondFactor;
        }
        let path = `/buildpacks/${encodeURIComponent(buildpack)}/actions/archive`;
        let response = await this.api.post(path, undefined, this.api.headers(options));
        if (response.status === 200) {
            return true_myth_1.Result.ok(await response.json());
        }
        else {
            return true_myth_1.Result.err({
                status: response.status,
                path,
                description: await response.text(),
            });
        }
    }
    async revisionInfo(buildpack, revision_id) {
        let path = `/buildpacks/${encodeURIComponent(buildpack)}/revisions/${encodeURIComponent(revision_id)}`;
        let response = await this.api.get(path);
        if (response.status === 200) {
            return true_myth_1.Result.ok(await response.json());
        }
        else {
            return true_myth_1.Result.err({
                status: response.status,
                path,
                description: await response.text(),
            });
        }
    }
    async buildpackExists(buildpack) {
        return this.api.get(`/buildpacks/${encodeURIComponent(buildpack)}`);
    }
    async listVersions(buildpack) {
        let path = `/buildpacks/${encodeURIComponent(buildpack)}/revisions`;
        let response = await this.api.get(path);
        if (response.status === 200) {
            return true_myth_1.Result.ok(await response.json());
        }
        else {
            return true_myth_1.Result.err({
                status: response.status,
                path,
                description: await response.text()
            });
        }
    }
    async delay(ms) {
        // Disable lint is Temporary
        // until this issue is resolved https://github.com/Microsoft/tslint-microsoft-contrib/issues/355#issuecomment-407209401
        // tslint:disable-next-line no-string-based-set-timeout
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    async waitForRelease(buildpack_id, revision_id) {
        let status = 'failed';
        let status_count = 0;
        let running = true;
        while (running) {
            status_count += 1;
            let result = await this.revisionInfo(buildpack_id, revision_id);
            if (result.isOk()) {
                let revision = result.unsafelyUnwrap();
                status = revision.status;
                if (status !== 'pending') {
                    break;
                }
                if (status_count === 60) {
                    break;
                }
            }
            await this.delay(2000);
        }
        return status;
    }
}
exports.BuildpackRegistry = BuildpackRegistry;
