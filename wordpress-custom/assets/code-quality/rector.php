<?php

// rector.php — WordPress automated refactors. Seeded once (overwrite:false) —
// yours to tune. Update the paths to your custom theme(s)/plugin(s).

declare(strict_types=1);

// use Fsylum\RectorWordPress\Set\WordPressSetList; // optional: require fsylum/rector-wordpress
use Rector\Config\RectorConfig;
use Rector\Set\ValueObject\LevelSetList;
use Rector\Set\ValueObject\SetList;
use Rector\ValueObject\PhpVersion;

return static function (RectorConfig $rectorConfig): void {
    // Load sets for modernization.
    $rectorConfig->sets([
        // WordPressSetList::WP_6_8,    // WordPress rules (needs fsylum/rector-wordpress)
        LevelSetList::UP_TO_PHP_83,     // Core Rector rules for PHP 8.3
        SetList::CODE_QUALITY,          // Code quality improvements
        SetList::TYPE_DECLARATION,      // Add type hints
        SetList::DEAD_CODE,             // Remove unused code
        SetList::EARLY_RETURN,          // Convert nested ifs to early returns
        SetList::NAMING,                // Improve naming consistency
    ]);

    $rectorConfig->phpVersion(PhpVersion::PHP_83);

    // Your custom code — update to your theme/plugin paths.
    $rectorConfig->paths([
        __DIR__ . '/wp-content/themes/mytheme',
    ]);

    // Skip generated / vendor / cache / core files.
    $rectorConfig->skip([
        __DIR__ . '/vendor/*',
        __DIR__ . '/node_modules/*',
        __DIR__ . '/wp-content/uploads/*',
        __DIR__ . '/wp-content/cache/*',
        __DIR__ . '/wp-admin/*',
        __DIR__ . '/wp-includes/*',
    ]);

    $rectorConfig->cacheDirectory(__DIR__ . '/.rector-cache');
    $rectorConfig->parallel();
};
