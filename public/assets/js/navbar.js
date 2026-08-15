/**
 * ARTHINGS - Shared Navigation
 *
 * One source of truth for the header and mobile menu.
 *
 * The site previously carried three hand-maintained copies of the navbar,
 * which had drifted apart: moving from the map to a listing page silently
 * dropped the "Оренда житла" entry, because that page still had an older
 * copy. Rendering it from here keeps every page identical by construction.
 *
 * Emits the same ids and classes the rest of the app already binds to
 * (#auth-links, #user-links, #user-name, .logout-btn, .mobile-menu-btn),
 * so main.js's checkAuth()/updateAuthUI() keep working untouched.
 */

(function () {
    'use strict';

    /** Primary navigation. `match` decides which entry is highlighted. */
    const LINKS = [
        { href: '/', label: 'Оренда речей', i18n: 'nav.rentItems', match: p => p === '/' || p === '/index.html' },
        { href: '/pages/housing.html', label: 'Оренда житла', i18n: 'nav.rentHousing', match: p => p.includes('housing') },
        { href: '/pages/map.html', label: 'Карта', i18n: 'nav.map', match: p => p.includes('map') },
        { href: '/pages/rental-requests.html', label: 'Запити', i18n: 'nav.requests', match: p => p.includes('rental-requests') },
        { href: '/pages/about.html', label: 'Про нас', i18n: 'nav.about', match: p => p.includes('about') },
        { href: '/pages/contact.html', label: 'Контакти', i18n: 'nav.contact', match: p => p.includes('contact') }
    ];

    /** Entries inside the signed-in dropdown. */
    const USER_LINKS = [
        { href: '/pages/profile.html', label: 'Профіль', i18n: 'nav.profile' },
        { href: '/pages/my-listings.html', label: 'Мої оголошення', i18n: 'nav.myListings' },
        { href: '/pages/my-rentals.html', label: 'Мої оренди', i18n: 'nav.myRentals' },
        { href: '/pages/messages.html', label: 'Повідомлення', i18n: 'nav.messages' },
        { href: '/pages/favorites.html', label: 'Обране', i18n: 'nav.favorites' }
    ];

    function escapeHtml(value) {
        return String(value ?? '')
            .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    }

    const path = window.location.pathname;

    function navLinks(className) {
        return LINKS.map(link => {
            const active = link.match(path) ? ' active' : '';
            return `<a href="${link.href}" class="${className}${active}" data-i18n="${link.i18n}">${escapeHtml(link.label)}</a>`;
        }).join('\n            ');
    }

    function dropdownLinks() {
        return USER_LINKS.map(link =>
            `<a href="${link.href}" data-i18n="${link.i18n}">${escapeHtml(link.label)}</a>`
        ).join('\n                            ');
    }

    const markup = `
    <nav class="navbar">
        <div class="navbar-container">
            <a href="/" class="navbar-brand">
                <img src="/assets/images/logo.png" alt="Arthings" class="navbar-logo">
                <span class="navbar-title">Arthings</span>
            </a>

            <div class="navbar-nav">
            ${navLinks('nav-link')}
            </div>

            <div class="navbar-actions">
                <div class="lang-switcher">
                    <button class="lang-btn active" data-lang="en">EN</button>
                    <button class="lang-btn" data-lang="uk">UK</button>
                </div>

                <div id="auth-links">
                    <a href="/pages/login.html" class="btn btn-ghost" data-i18n="nav.login">Увійти</a>
                    <a href="/pages/register.html" class="btn btn-primary" data-i18n="nav.register">Реєстрація</a>
                </div>

                <div id="user-links" class="hidden">
                    <a href="/pages/add-item.html" class="btn btn-primary" data-i18n="nav.addItem">Додати</a>
                    <div class="user-dropdown">
                        <button class="btn btn-ghost user-menu-btn">
                            <span id="user-name">User</span>
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <polyline points="6 9 12 15 18 9"></polyline>
                            </svg>
                        </button>
                        <div class="dropdown-menu">
                            ${dropdownLinks()}
                            <hr>
                            <a href="#" class="logout-btn" data-i18n="nav.logout">Вийти</a>
                        </div>
                    </div>
                </div>
            </div>

            <button class="mobile-menu-btn" aria-label="Toggle menu">
                <span></span><span></span><span></span>
            </button>
        </div>
    </nav>

    <div class="mobile-nav">
        ${navLinks('mobile-nav-link')}
        <hr>
        <div id="mobile-auth-links">
            <a href="/pages/login.html" class="mobile-nav-link" data-i18n="nav.login">Увійти</a>
            <a href="/pages/register.html" class="mobile-nav-link" data-i18n="nav.register">Реєстрація</a>
        </div>
        <div id="mobile-user-links" class="hidden">
            <a href="/pages/add-item.html" class="mobile-nav-link" data-i18n="nav.addItem">Додати</a>
            ${USER_LINKS.map(l => `<a href="${l.href}" class="mobile-nav-link" data-i18n="${l.i18n}">${escapeHtml(l.label)}</a>`).join('\n            ')}
            <a href="#" class="mobile-nav-link logout-btn" data-i18n="nav.logout">Вийти</a>
        </div>
    </div>`;

    /**
     * Replaces any navbar already in the page, so pages can be migrated one
     * at a time without ending up with two headers.
     */
    function render() {
        const existingNav = document.querySelector('nav.navbar');
        const existingMobile = document.querySelector('.mobile-nav');
        if (existingMobile) existingMobile.remove();

        const holder = document.createElement('div');
        holder.innerHTML = markup;

        if (existingNav) {
            existingNav.replaceWith(...holder.childNodes);
        } else {
            document.body.insertBefore(holder, document.body.firstChild);
            // Unwrap so the navbar is a direct child of body, as the CSS expects.
            holder.replaceWith(...holder.childNodes);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', render);
    } else {
        render();
    }
})();
