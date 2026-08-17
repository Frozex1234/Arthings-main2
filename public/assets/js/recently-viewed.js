/**
 * ARTHINGS - Recently Viewed Listings
 *
 * Stored client-side rather than in the database.
 *
 * Most homepage traffic is anonymous, and a server-side history would only
 * work for signed-in users — the visitors least likely to have one. It also
 * keeps a high-frequency write off the request path: every listing view would
 * otherwise mean a database round trip.
 *
 * The trade-off is that history is per-browser and does not follow the user
 * across devices. For a "продовжити перегляд" rail that is an acceptable
 * exchange; if it ever needs to sync, this module is the single place that
 * would change.
 */

(function (global) {
    'use strict';

    const STORAGE_KEY = 'arthings-recently-viewed';
    const MAX_ENTRIES = 20;

    function read() {
        try {
            const raw = localStorage.getItem(STORAGE_KEY);
            if (!raw) return [];
            const parsed = JSON.parse(raw);
            return Array.isArray(parsed) ? parsed.filter(id => typeof id === 'string') : [];
        } catch {
            // Private browsing, a full quota or hand-edited junk — none of
            // which should break the page that called us.
            return [];
        }
    }

    function write(ids) {
        try {
            localStorage.setItem(STORAGE_KEY, JSON.stringify(ids.slice(0, MAX_ENTRIES)));
        } catch {
            /* storage unavailable — history is a nicety, not a requirement */
        }
    }

    /**
     * Records a view, moving an already-seen listing back to the front.
     * @param {string} productId - prefixed id, e.g. "prod-12"
     */
    function recordView(productId) {
        if (!productId) return;
        const ids = read().filter(id => id !== productId);
        ids.unshift(productId);
        write(ids);
    }

    /**
     * @param {number} [limit]
     * @returns {string[]} most recently viewed first
     */
    function getViewed(limit = MAX_ENTRIES) {
        return read().slice(0, limit);
    }

    function clearViewed() {
        try {
            localStorage.removeItem(STORAGE_KEY);
        } catch {
            /* nothing to do */
        }
    }

    /**
     * Fetches the stored listings in one request.
     *
     * The API cannot preserve our ordering (an `IN` clause has none), so the
     * results are re-sorted here to match view recency. Listings deleted since
     * they were viewed simply do not come back, and are dropped from storage.
     *
     * @param {number} [limit]
     * @returns {Promise<Array>}
     */
    async function fetchViewed(limit = 8) {
        const ids = getViewed(limit);
        if (!ids.length) return [];

        try {
            const params = new URLSearchParams({ ids: ids.join(','), limit: String(ids.length) });
            const data = await api.get(`/api/products?${params}`);
            const byId = new Map((data.products || []).map(product => [product.id, product]));

            const found = ids.map(id => byId.get(id)).filter(Boolean);

            // Prune ids the server no longer knows about, so the rail does not
            // shrink silently every visit.
            if (found.length !== ids.length) {
                const alive = new Set(found.map(product => product.id));
                write(read().filter(id => alive.has(id) || !ids.includes(id)));
            }

            return found;
        } catch (error) {
            console.error('Failed to load recently viewed:', error);
            return [];
        }
    }

    global.recentlyViewed = { recordView, getViewed, clearViewed, fetchViewed };
})(window);
