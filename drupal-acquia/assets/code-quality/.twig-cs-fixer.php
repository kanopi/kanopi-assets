<?php

// .twig-cs-fixer.php — Drupal Twig coding standards. Seeded once
// (overwrite:false) — yours to tune. Modeled on kanopi/drupal-starter. Lint
// paths come from the composer `twig-lint` / `twig-lint-ci` scripts.

$finder = new TwigCsFixer\File\Finder();
$finder->exclude('tests');

$config = new TwigCsFixer\Config\Config();
$config->setFinder($finder);
$config->setCacheFile(null);
# See https://www.drupal.org/project/drupal/issues/3284817#comment-15780893
#$config->addTokenParser(new Drupal\Core\Template\TwigTransTokenParser());

return $config;
