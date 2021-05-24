"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var Fixture;
(function (Fixture) {
    function buildpack(options) {
        let base = {
            id: '3ef8f543-b953-4a26-b410-8807d1b45eb1',
            name: 'scala',
            created_at: new Date(),
            updated_at: new Date(),
            description: 'Official Heroku Buildpack for Scala',
            category: 'languages',
            two_factor_authentication: false,
            blob_url: 'https://buildpack-registry.s3.amazonaws.com/buildpacks/heroku/scala.tgz',
            source: {
                type: 'github',
                owner: 'heroku',
                repo: 'heroku-buildpack-scala'
            },
            support: { method: 'github', address: null },
            namespace: 'heroku',
            logo: {
                small: {
                    url: 'https://s3.amazonaws.com/buildpack-registry/images/buildpacks/logos/3ef/8f5/43-/small/data?1526489067',
                    width: 64,
                    height: 64
                },
                medium: {
                    url: 'https://s3.amazonaws.com/buildpack-registry/images/buildpacks/logos/3ef/8f5/43-/medium/data?1526489067',
                    width: 128,
                    height: 128
                }
            }
        };
        if (options) {
            return Object.assign({}, base, options);
        }
        else {
            return base;
        }
    }
    Fixture.buildpack = buildpack;
    function revision(options) {
        let base = {
            id: '8de70dbe-e862-4d51-b906-123ef3bf2fc5',
            buildpack_id: '71a3c00a-d6c7-4393-94c5-d5d71531720e',
            published_by_email: undefined,
            ref: undefined,
            tarball: 'https://buildpack-registry.s3.amazonaws.com/buildpacks/heroku/scala-v151.tgz',
            status: 'published',
            error: undefined,
            created_at: new Date(),
            updated_at: new Date(),
            release: 151,
            checksum: '3fc5aa90fcdc97b2a22a9bba1dac07323dd12d3d4e0abc1984fb06e6e15bc649',
            published_by_id: 'bebd5adc-2194-41c9-a246-d97af547a3f9',
            license: 'MIT'
        };
        if (options) {
            return Object.assign({}, base, options);
        }
        else {
            return base;
        }
    }
    Fixture.revision = revision;
    function readme(options) {
        let base = {
            content: 'IyBIZXJva3UgRXhlYyBCdWlsZHBhY2sKClRoaXMgaXMgYSBbSGVyb2t1IEJ1\naWxkcGFja10oaHR0cHM6Ly9kZXZjZW50ZXIuaGVyb2t1LmNvbS9hcnRpY2xl\ncy9idWlsZHBhY2tzKQp0aGF0IHdvcmtzIHdpdGggdGhlIFtIZXJva3UgRXhl\nY10oaHR0cHM6Ly9kZXZjZW50ZXIuaGVyb2t1LmNvbS9hcnRpY2xlcy9oZXJv\na3UtZXhlYykgZmVhdHVyZS4K\n',
            encoding: 'base64',
            sha: 'a5e1e5f5eb76095087b32b31caf5ccaee0c2cae6'
        };
        if (options) {
            return Object.assign({}, base, options);
        }
        else {
            return base;
        }
    }
    Fixture.readme = readme;
})(Fixture = exports.Fixture || (exports.Fixture = {}));
