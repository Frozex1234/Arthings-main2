/**
 * ARTHINGS - Loading Screen
 *
 * A brief branded splash built around the logo.
 *
 * Loaded from <head> and appended to documentElement rather than body, so it
 * can cover the page from the very first paint — body does not exist yet at
 * that point, and waiting for it would let unstyled content flash through
 * first.
 *
 * Styles are injected inline instead of living in main.css: the stylesheet may
 * still be loading when this runs, and a splash screen that appears unstyled
 * is worse than none at all.
 */

(function () {
    'use strict';

    // Long enough to read as deliberate, short enough not to be a toll gate.
    const MIN_VISIBLE_MS = 500;
    // Hard ceiling: the splash must never outlive a stalled page and trap the
    // visitor behind an opaque overlay.
    const MAX_VISIBLE_MS = 3000;

    const startedAt = Date.now();

    const style = document.createElement('style');
    style.textContent = `
        #arthings-preloader {
            position: fixed;
            inset: 0;
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #0f172a 100%);
            opacity: 1;
            transition: opacity .45s ease;
        }

        #arthings-preloader.is-leaving { opacity: 0; }

        .arthings-preloader-mark {
            position: relative;
            width: 120px;
            height: 120px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Ring sweeping around the mark. A conic gradient masked into a ring
           gives a single travelling arc without extra elements. */
        .arthings-preloader-ring {
            position: absolute;
            inset: 0;
            border-radius: 50%;
            background: conic-gradient(from 0deg, rgba(0,209,205,0) 0deg,
                        rgba(0,209,205,.15) 180deg, #00d1cd 340deg, #00d1cd 360deg);
            -webkit-mask: radial-gradient(farthest-side, transparent calc(100% - 3px), #000 calc(100% - 3px));
            mask: radial-gradient(farthest-side, transparent calc(100% - 3px), #000 calc(100% - 3px));
            animation: arthings-spin 1.1s linear infinite;
        }

        .arthings-preloader-logo {
            width: 62px;
            height: 62px;
            object-fit: contain;
            animation: arthings-pulse 1.6s ease-in-out infinite;
        }

        .arthings-preloader-name {
            position: absolute;
            top: calc(50% + 86px);
            left: 50%;
            transform: translateX(-50%);
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            font-size: 15px;
            font-weight: 700;
            letter-spacing: .18em;
            text-transform: uppercase;
            color: rgba(255,255,255,.55);
            animation: arthings-fade 1.6s ease-in-out infinite;
        }

        @keyframes arthings-spin { to { transform: rotate(360deg); } }

        @keyframes arthings-pulse {
            0%, 100% { transform: scale(1); opacity: .9; }
            50%      { transform: scale(1.09); opacity: 1; }
        }

        @keyframes arthings-fade {
            0%, 100% { opacity: .4; }
            50%      { opacity: .85; }
        }

        /* Honour a reduced-motion preference: keep the branding, drop the
           movement. */
        @media (prefers-reduced-motion: reduce) {
            .arthings-preloader-ring,
            .arthings-preloader-logo,
            .arthings-preloader-name { animation: none; }
            .arthings-preloader-ring { opacity: .5; }
        }
    `;

    const overlay = document.createElement('div');
    overlay.id = 'arthings-preloader';
    overlay.setAttribute('role', 'status');
    overlay.setAttribute('aria-label', 'Завантаження');
    overlay.innerHTML = `
        <div class="arthings-preloader-mark">
            <div class="arthings-preloader-ring"></div>
            <img class="arthings-preloader-logo" src="/assets/images/logo.png" alt="">
            <span class="arthings-preloader-name">Arthings</span>
        </div>`;

    document.documentElement.appendChild(style);
    document.documentElement.appendChild(overlay);

    let removed = false;

    function hide() {
        if (removed) return;
        removed = true;

        overlay.classList.add('is-leaving');
        // Remove only after the fade, so the node does not linger and keep
        // intercepting clicks.
        setTimeout(() => overlay.remove(), 500);
    }

    /** Waits out the minimum display time before fading. */
    function finish() {
        const elapsed = Date.now() - startedAt;
        setTimeout(hide, Math.max(0, MIN_VISIBLE_MS - elapsed));
    }

    if (document.readyState === 'complete') {
        finish();
    } else {
        window.addEventListener('load', finish);
    }

    // Safety net, independent of the load event ever firing.
    setTimeout(hide, MAX_VISIBLE_MS);
})();
