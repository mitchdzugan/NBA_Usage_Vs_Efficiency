(import [toolz.itertoolz [*]])
(import [toolz.functoolz [*]])
(import [toolz.dicttoolz [*]])
(import [urllib2 [*]])
(import [urlparse [*]])
(import [os.path [*]])
(import [time [*]])
(import [bs4 [*]])
(import [pprint [pprint]])
(require [hy.contrib.anaphoric [*]])

(setv last-request-time (time))
(defn make-request
  [url]
  (global last-request-time)
  (sleep (max 0.0 (- 15.0 (- (time) last-request-time))))
  (setv last-request-time (time))
  (pprint last-request-time)
  (-> url urlopen .read))

(defn get-page
  [url]
  (let [path (+ "./cache" (. (urlparse url) path))]
    (if (isfile path)
      (let [f (open path "r")
            html (.read f)]
        (.close f)
        html)
      (let [f (open path "w")
            html (make-request url)]
        (.write f html)
        (.close f)
        html))))

(def pbp-links (list (reduce (fn [pbp-links month]
                        (let [game-rows (-> (+ "http://www.basketball-reference.com/leagues/NBA_2016_games-"
                                               month
                                               ".html")
                                            get-page
                                            (BeautifulSoup "html.parser")
                                            (.find :id "schedule")
                                            (. tbody)
                                            (.find_all "tr"))]
                          (concatv
                           pbp-links
                           (map (fn [game-row]
                                  (-> game-row (. children) list
                                      (get 6) (. a) (get "href")
                                      (.replace "boxscores" "boxscores/pbp")))
                                (filter (fn [game-row]
                                          (not (.has_key game-row "class")))
                                        game-rows)))))
                             ["october" "november" "december" "january" "february" "march" "april" "may" "june"] [])))

(pprint (len (list (map (fn [pbp-link]
                          (get-page (+ "http://www.basketball-reference.com/" pbp-link))
                          1)
                        pbp-links))))
(pprint (len pbp-links))

