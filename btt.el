;; btt.el - BetterTouchTool integration for Emacs on OSX
;;   This is a series of functions and keybindings, some of which utilize
;;   BTTs integrated web server for displaying information.
;;   It can be extended in the future to support status displays on other
;;   external devices that can be controlled in a similar manner.
;;
;; Copyright (c) 2020   David E. <david(at)empireofgames.com>
;;
;; (MIT License)
;;
;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files (the "Software"), to deal in the Software without
;; restriction, including without limitation the rights to use, copy,
;; modify, merge, publish, distribute, sublicense, and/or sell copies
;; of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
;; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.
;;


;; BTT Access Configuration.
; If using https, security keys, or remote access modify this appropriately
(setq btt-base-uri "http://127.0.0.1:8080")

;; UUID Configurations matching accompanying bttpreset definitions
(setq btt-buf-name-uuid "164BBAC3-4F14-4487-BFCE-8A5EEC658761")
(setq btt-buf-line-no-uuid "56742687-6B6E-4514-982F-648CC44457ED")
(setq btt-mode-name-uuid "BB3FA5C7-8F78-4A86-AD4D-ABBB35658ADC")
(setq btt-eyebrowse-uuid "564B694D-F515-4170-AD2F-8123C0014C55")

(setq btt-subgroup-uuids '(
                           "5A9EB530-9511-4460-B570-5D36B12294BF"
                           "F248CD4B-23C3-4190-9C50-D807EB4201F7"
                           "0AD48725-AE42-474D-A8FD-F100C97AF599"
                           "B1319FFC-FEC9-40B7-9615-B27F97EBD7E2"
                           "3A05DC1C-B5D2-408F-A0B8-CABF60F9CCC2"
                           "6C93399A-66D8-4D4D-877B-3D8DD6E0BA8F"
                           "C65818F2-7822-485D-AC8E-8B32BD445E58"
                           "8B9754A4-17DC-440A-B2A2-89C572F89B3C"
                           "06B92AB4-B68A-42B8-9962-DCCBB9222177"
                           "71A05D58-A88B-4E07-A59A-7202DB3A0E3B"
                           ))
(setq btt-subgroup-close-uuid "9BCC78A1-63E0-414A-B5C9-E7E871271175")

;; Internal State Variables
(setq btt-subgroup-titles nil)
(setq btt-subgroup-name nil)
(setq btt-subgroup-titles-data nil)


(defun btt-update-text (uuid txt)
  "Update BTT Widget with specified Text"
(let (
      ;; Setup Variables
      (tmp-url 
      (concat
       btt-base-uri
       "/update_touch_bar_widget/?uuid="
       uuid
       "&text="
       (url-hexify-string txt)
       )
      )
      )
  ;; Execute
  (url-retrieve
   tmp-url
   (lambda (status) (kill-buffer)) ; We don't care about results, but need to delete the results
   )
)
)

(defun btt-subgroup-close ()
  "Close open subgroup"
  ;; TODO: Move common part into a new function
(let (
      ;; Setup Variables
      (tmp-url 
      (concat
       btt-base-uri
       "/execute_assigned_actions_for_trigger/?uuid="
       btt-subgroup-close-uuid
       )
      )
      )
  ;; Execute
  (url-retrieve
   tmp-url
   (lambda (status) (kill-buffer)) ; We don't care about results, but need to delete the results
   )
)
  
)

(defun btt-refresh-subgroup-list ()
  "Refresh titles of subgroup from the cache"
  (interactive)
  (dotimes (idx (length btt-subgroup-uuids))
    (let ( (title (nth idx btt-subgroup-titles))
           (uuid (nth idx btt-subgroup-uuids))
           )
      (btt-update-text uuid title)
     )
    )
  )

;;; Recent Buffers Widget Sybgroup
;; Display/Refresh Subgroup List of Recent Buffers
(defun btt-update-subgroup-to-recent-bufs ()
    "Update subgroup buttons to list recent buffers"
    (interactive)
  (let ( (bufs (buffer-list) )
         (name)
         (tmp-list)
         )
    (dolist (uuid btt-subgroup-uuids)
      
      (setq name (buffer-name (pop bufs)))

      ;; Skip over any hidden buffers
      (while (and bufs (string= (substring name 0 1) " ") )
        (setq name (buffer-name (pop bufs)))
        )

      ;; Display Name & Cache
      (btt-update-text uuid name)
        (add-to-list 'tmp-list name)
      )
    (setq btt-subgroup-titles tmp-list)
    (setq btt-subgroup-name "bufs")
    )
  )
(defun btt-subgroup-exec-bufs (num)
  "Switch to buffer name corresponding to selected button"
  ;; Get num element from btt-subgroup-titles
  (let (
      (buf (get-buffer
            (nth (- (length btt-subgroup-titles) num) btt-subgroup-titles) ;; Buffer title from list
            )) ; Get buffer by name
      )
   (when buf
     (switch-to-buffer buf)
     )
   )
  )



;; Define state variables (for performance optimization)
(setq btt-update-window-cb-buf-name nil)
(setq btt-update-window-cb-line-no "")
(setq btt-update-window-cb-mode-name "")

(defun btt-update-window-cb ()
  "Update configured Widgets when something changes. This is intended to be called via window-configuration-change-hook"
  (let (   (new-buf-name (buffer-name))
           (new-line-no (line-number-at-pos))
           )
  (when (not (eq btt-update-window-cb-buf-name new-buf-name) )
      (btt-update-text btt-buf-name-uuid new-buf-name )
    (setq btt-update-window-cb-buf-name new-buf-name )
      )
  (when (not (eq btt-update-window-cb-line-no new-line-no))
      (btt-update-text btt-buf-line-no-uuid
                       (format "%d "new-line-no)
                       )
    (setq btt-update-window-cb-line-no new-line-no )
    )
  (when (not (eq btt-update-window-cb-mode-name mode-name))
      (btt-update-text btt-mode-name-uuid mode-name )
    (setq btt-update-window-cb-mode-name mode-name)
    ;; TODO: Add logic to update mode-specific widgets as needed (ie: paren match, fn name, etc)
    )

  ))

;; Post-Command Hook to update Touhbar whenever a buffer changes
(add-hook 'post-command-hook 'btt-update-window-cb )


;; Eyebrowse Mode: Show current selection
(when (fboundp 'eyebrowse-mode)
(defun btt-update-eyebrowse ()
  "Update Eyebrowse Modeline Display"
  (btt-update-text btt-eyebrowse-uuid
                   (eyebrowse-format-slot
                    (assoc
                     (eyebrowse--get 'current-slot)
                      (eyebrowse--get 'window-configs) ;; window-configs
                      )
                    )
                   )
  ) ; End btt-update-eyebrowse

(defun btt-update-subgroup-to-eyebrowse ()
  "Display eyebrowse workspaces in subgroup"
  (interactive)
  (let ( (list) (idxs) )
    (dolist (cfg (eyebrowse--get 'window-configs) )
      (add-to-list 'list (eyebrowse-format-slot cfg) t ) ;; Add to end of list for correct ordering
      (add-to-list 'idxs (car cfg) t )
      )
    (setq btt-subgroup-titles list)
    (setq btt-subgroup-titles-data idxs)
    (setq btt-subgroup-name "eyebrowse")
    (btt-refresh-subgroup-list)
    )
  )

(add-hook 'eyebrowse-post-window-switch-hook 'btt-update-eyebrowse)

) ; End when eyebrowse-mode defined



(defun btt-subgroup-exec-key (num)
  "Execute action associated with subgroup key. Note key 1 is the first/leftmost button"
  (interactive)
  (cond
   ( (string= btt-subgroup-name "bufs") ;; recent-bufs list is active
     (btt-subgroup-exec-bufs num) ;; Switch file
     (btt-subgroup-close) ;; Close group
     )

   ( (string= btt-subgroup-name "eyebrowse")
     (eyebrowse-switch-to-window-config (nth (- num 1) btt-subgroup-titles-data))
     (btt-subgroup-close)
     )
 
     ) ;; End cond
  )

;;;; Set BTT Subgroup Bindings.
; Macro to easily utilize lambda functions in bindings below
    (defmacro aif (&rest forms)
      "Create an anonymous interactive function.
    Mainly for use when binding a key to a non-interactive function."
      `(lambda () (interactive) ,@forms))


;; Deliberately awkward sequences have been chosen as they are only intended to be called by macros (ie: BTT or other keyboard emulator)
;; All subgrooup bindings will be consolidated here for readability
(global-set-key (kbd "C-M-S-<f1>") 'btt-update-subgroup-to-recent-bufs)
(global-set-key (kbd "C-M-S-<f2>") 'btt-update-subgroup-to-eyebrowse)


;; Subgroup Button bindings
(global-set-key (kbd "A-C-M-S-<f1>") (aif (btt-subgroup-exec-key 1) ) )
(global-set-key (kbd "A-C-M-S-<f2>") (aif (btt-subgroup-exec-key 2) ) )
(global-set-key (kbd "A-C-M-S-<f3>") (aif (btt-subgroup-exec-key 3) ) )
(global-set-key (kbd "A-C-M-S-<f4>") (aif (btt-subgroup-exec-key 4) ) )
(global-set-key (kbd "A-C-M-S-<f5>") (aif (btt-subgroup-exec-key 5) ) )
(global-set-key (kbd "A-C-M-S-<f6>") (aif (btt-subgroup-exec-key 6) ) )
(global-set-key (kbd "A-C-M-S-<f7>") (aif (btt-subgroup-exec-key 7) ) )
(global-set-key (kbd "A-C-M-S-<f8>") (aif (btt-subgroup-exec-key 8) ) )
(global-set-key (kbd "A-C-M-S-<f9>") (aif (btt-subgroup-exec-key 9) ) )
(global-set-key (kbd "A-C-M-S-<f10>") (aif (btt-subgroup-exec-key 10) ) )


;; Bookmarks keybindings
;; (global-set-key (kbd "<C-f2>") 'bm-toggle)
;; (global-set-key (kbd "<f2>") 'bm-next)
;; (global-set-key (kbd "<S-f2>") 'bm-previous)
;; (global-set-key (kbd "<M-f2>") 'bm-bookmark-show-annotation) ;; Maybe change from Meta to Cmd?
;; (global-set-key (kbd "<M-S-f2>") 'bm-bookmark-annotate)
;; (global-set-key (kbd "<A-f2>") 'bm-show-all)






