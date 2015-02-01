var gulp = require('gulp');
var browserify = require("browserify");
var to5Browserify = require("6to5-browserify");
var source = require('vinyl-source-stream');
var uglify = require('gulp-uglify');
var buffer = require('vinyl-buffer');
var sourcemaps = require('gulp-sourcemaps');
var sass = require('gulp-sass');

gulp.task('default', ['build']);

gulp.task('build', ['web', 'web-src', 'sass']);

gulp.task('web', function() {
  return gulp.src(['./web/*'])
    .pipe(gulp.dest('build/web'));
});

var getBundleName = function () {
  var version = require('./package.json').version;
  var name = require('./package.json').name;
  return version + '.' + name + '.' + 'min';
};

gulp.task('sass', function() {
  return gulp.src('./sass/*')
    .pipe(sass())
    .pipe(gulp.dest('build/web'));
});

gulp.task('web-src', function() {

  var bundler = browserify({
    entries: ['./web-src/index.js'],
    debug: true
  });

  var bundle = function() {
    return bundler
      .transform(to5Browserify)
      .bundle()
      .pipe(source(getBundleName() + '.js'))
      .pipe(buffer())
   /*   .pipe(sourcemaps.init({loadMaps: true}))
        .pipe(uglify())
      .pipe(sourcemaps.write('./'))*/
      .pipe(gulp.dest('./build/web/'));
  };

  return bundle();
});
