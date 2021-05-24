import { Result } from 'true-myth';
import { BuildpackBody, BuildpackRegistryApi as Api, Category, ReadmeBody, Response, RevisionBody, RevisionStatus } from './buildpack-registry-api';
export { BuildpackBody, Category, ReadmeBody, RevisionBody, RevisionStatus };
export declare type BuildpackSlugResult = {
    result: boolean;
    error?: string;
};
export declare type ResponseError = {
    status: number;
    path: string;
    description: string;
};
export declare type InfoData = {
    license: string;
    category?: string;
    description: string;
    readme?: string;
    support?: string;
    source?: string;
};
export declare class BuildpackRegistry {
    static isValidBuildpackSlug(buildpack: string): Result<boolean, string>;
    api: Api;
    constructor();
    requiresTwoFactor(buildpack: string): Promise<Result<boolean, ResponseError>>;
    publish(buildpack: string, ref: string, token: string, secondFactor?: string): Promise<Result<RevisionBody, ResponseError>>;
    rollback(buildpack: string, token: string, secondFactor?: string): Promise<Result<RevisionBody, ResponseError>>;
    search(namespace?: string, name?: string, description?: string): Promise<Result<BuildpackBody[], ResponseError>>;
    info(buildpack: string): Promise<Result<InfoData, ResponseError>>;
    archive(buildpack: string, token: string, secondFactor?: string): Promise<Result<BuildpackBody, ResponseError>>;
    revisionInfo(buildpack: string, revision_id: string): Promise<Result<RevisionBody, ResponseError>>;
    buildpackExists(buildpack: string): Promise<Response>;
    listVersions(buildpack: string): Promise<Result<RevisionBody[], ResponseError>>;
    delay(ms: number): Promise<{}>;
    waitForRelease(buildpack_id: string, revision_id: string): Promise<RevisionStatus>;
}
