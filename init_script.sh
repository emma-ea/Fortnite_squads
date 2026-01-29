#!/bin/bash

# Create root directories
mkdir -p lib/config
mkdir -p lib/core/{constants,theme,utils,errors,network/interceptors,services}
mkdir -p lib/data/{models,repositories,datasources/{remote,local}}
mkdir -p lib/domain/{entities,usecases/{auth,user,squad,session}}
mkdir -p lib/presentation/{blocs/{auth,user,squad,session,notification},screens/{splash,auth/widgets,onboarding,home/widgets,discover/widgets,squads/widgets,sessions/widgets,messaging/widgets,notifications/widgets,settings},widgets/common,routes}

# Create placeholder files to ensure git tracks directories
touch lib/config/{app_config.dart,api_config.dart,firebase_config.dart}
touch lib/core/constants/{api_constants.dart,app_constants.dart,route_constants.dart,storage_keys.dart}
touch lib/core/network/dio_client.dart
touch lib/injection_container.dart
touch lib/app.dart

echo "✅ Squad Finder Architecture setup complete!"
