TEST_ENVIRONMENT_DEFAULT_ATTRIBUTES = {
  'chef-server' => {
    'version' => '1.0.0',
    'package_source' => 'aws',
    'api_fqdn' => 'server.domain.com',
    'topology' => 'standalone',
    'accept_license' => true,
    'configuration' => {
      'nginx' => {
        'port' => 4433
      }
    }
  },
  'yum' => {
    'main' => {
      'alwaysprompt' => true,
      'assumeyes' => true
    }
  }
}

STAGING_ENVIRONMENT_DEFAULT_ATTRIBUTES = {
  'chef-server' => {
    'version' => '2.0.0',
    'package_source' => 'aws',
    'api_fqdn' => 'server.domain.com',
    'topology' => 'standalone',
    'accept_license' => true,
    'configuration' => {
      'nginx' => {
        'port' => 36987
      }
    }
  },
  'yum' => {
    'main' => {
      'alwaysprompt' => true,
      'assumeyes' => true
    }
  }
}


PREPROD_ENVIRONMENT_DEFAULT_ATTRIBUTES = {
  'chef-server' => {
    'version' => '1.0.0',
    'package_source' => 'aws',
    'api_fqdn' => 'server.domain.com',
    'topology' => 'standalone',
    'accept_license' => true
  },
  'yum' => {
    'main' => {
      'alwaysprompt' => true,
      'assumeyes' => true
    }
  }
}
