import { Headers, Response } from 'node-fetch';
export { Response } from 'node-fetch';
export declare type IBody = {
    [property: string]: string;
};
export declare type RevisionStatus = 'pending' | 'published' | 'failed';
export declare type RevisionBody = {
    id: string;
    buildpack_id: string;
    published_by_email?: string;
    ref?: string;
    tarball?: string;
    status: RevisionStatus;
    error?: string;
    created_at: Date;
    updated_at: Date;
    release: number;
    checksum: string;
    published_by_id: string;
    license: string;
};
export declare type ReadmeBody = {
    content?: string;
    encoding?: string;
    sha?: string;
};
export declare type Category = 'languages' | 'tools' | 'packages';
export declare type BuildpackBody = {
    id: string;
    name: string;
    created_at: Date;
    updated_at: Date;
    description: string;
    category: Category;
    two_factor_authentication: boolean;
    blob_url: string;
    source: {
        type: 'github';
        owner: string;
        repo: string;
    };
    support: {
        method: 'github' | 'email' | 'website' | 'unsupported';
        address: string | null;
    };
    namespace: string;
    logo: {
        small: {
            url: string;
            width: number;
            height: number;
        };
        medium: {
            url: string;
            width: number;
            height: number;
        };
    };
};
export declare type HeaderOptions = {
    token?: string;
    secondFactor?: string;
};
export declare class BuildpackRegistryApi {
    static url(): string;
    static create(): BuildpackRegistryApi;
    headers(options?: HeaderOptions): Headers;
    post(path: string, body?: IBody, headers?: Headers): Promise<Response>;
    get(path: string): Promise<Response>;
}
