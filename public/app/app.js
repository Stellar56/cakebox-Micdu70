new ClipboardJS('.copybtn');

var app = angular.module('cakebox',  [
    'ngResource',
    'ngRoute',
    'ui.bootstrap',
    'pascalprecht.translate'
]);

app.config(['$locationProvider', function($locationProvider) {
  $locationProvider.hashPrefix('');
}]);

app.config(['$routeProvider', '$translateProvider',

    function($routeProvider, $translateProvider) {
        $routeProvider.
        when('/', {
            templateUrl: 'partials/browse.html',
            controller:  'BrowseCtrl'
        }).
        when('/browse/', {
            templateUrl: 'partials/browse.html',
            controller:  'BrowseCtrl'
        }).
        when('/browse/:path*', {
            templateUrl: 'partials/browse.html',
            controller:  'BrowseCtrl'
        }).
        when('/play/:path*', {
            templateUrl: 'partials/play.html',
            controller:  'MediaCtrl'
        }).
        when('/about', {
            templateUrl: 'partials/about.html'
        }).
        otherwise({
            redirectTo: '/'
        });

        $translateProvider.useStaticFilesLoader({
            prefix: 'ressources/languages/locale-',
            suffix: '.json'
        });
        $translateProvider.preferredLanguage('fr');
        $translateProvider.useSanitizeValueStrategy(null);
    }
]);
