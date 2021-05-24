import { BuildpackBody, ReadmeBody, RevisionBody } from '../../buildpack-registry';
export declare namespace Fixture {
    function buildpack(options?: Partial<BuildpackBody>): BuildpackBody;
    function revision(options?: Partial<RevisionBody>): RevisionBody;
    function readme(options?: Partial<ReadmeBody>): ReadmeBody;
}
