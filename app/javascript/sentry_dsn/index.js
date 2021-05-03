import * as Sentry from '@sentry/browser';

if( document.querySelector('[name="x-sentry-dsn"]') !== null && document.querySelector('[name="x-sentry-dsn"]').content !== '' ) {
  Sentry.init({
    dsn: document.querySelector('[name="x-sentry-dsn"]').content,
    release: document.querySelector('[name="x-sentry-release"]').content,
    environment: document.querySelector('[name="x-sentry-environment"]').content,
  });

  if( document.querySelector('[name="x-sentry-user-id"]').content !== '' ) {
    Sentry.configureScope((scope) => {
      scope.setUser({
        "id": document.querySelector('[name="x-sentry-user-id"]').content
      });
    });
  }
}
