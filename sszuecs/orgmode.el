; use git repo: git clone git://repo.or.cz/org-mode.git
;(add-to-list 'load-path "~/emacs-libs/org-mode/lisp")
;(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

; disable spell checker for this mode, because colors get messy.
(add-hook 'org-mode-hook
          (lambda ()
            (global-set-key "\C-cl" 'org-store-link)
            (global-set-key "\C-ca" 'org-agenda)
            (global-set-key "\C-cb" 'org-iswitchb)        ; switch buffer
            'turn-on-font-lock
            (setq flyspell-mode nil)))

;;;; org-mode customization
;; start folded
(setq org-startup-folded t)
;; related config
(setq org-return-follows-link t)
(run-at-time "00:59" 3600 'org-save-all-org-buffers)
(setq org-default-notes-file (expand-file-name (concat my-orgfile-dir "notes.org")))
; global Effort estimate values
(setq org-global-properties (quote (("Effort_ALL" . "0:10 0:30 1:00 2:00 3:00 4:00 5:00 6:00 7:00 8:00"))))
; do not archive done tasks
(setq org-archive-mark-done nil)

;;;
;;; TODO shortcuts
;;;
(setq org-todo-keywords
      '((sequence "TODO(t)" "INPROGRESS(i)" "|" "DONE(d!/!)" "DELEGATED(g@/!)")
        (sequence "WAITING(w@/!)" "SOMEDAY(s!)" "|" "CANCELLED(c@/!)")
        (sequence "OPEN(O)" "FIXME(f)" "|" "CLOSED(C!)")))
(setq org-todo-keyword-faces
      (quote (("TODO"       :foreground "red"          :weight bold)
              ("INPROGRESS" :foreground "orangered"    :weight bold)
              ("DONE"       :foreground "forest green" :weight bold)
              ("DELEGATED"  :foreground "forest green" :weight bold)
              ("WAITING"    :foreground "magenta"      :weight bold)
              ("SOMEDAY"    :foreground "goldenrod"    :weight bold)
              ("CANCELLED"  :foreground "olivedrab"    :weight bold)
              ("OPEN"       :foreground "red"          :weight bold)
              ("CLOSED"     :foreground "forest green" :weight bold)
              ;("FEEDBACK"   :foreground "magenta"      :weight bold)
              ;("EXPIRED"    :foreground "olivedrab1"   :weight bold)
              ;("REJECTED"   :foreground "olivedrab"    :weight bold)
              )))
;; auto-tag by state, makes for easy filtering, YAY!
(setq org-todo-state-tags-triggers
      (quote (("CANCELLED"  ("CANCELLED" . t))
              ("WAITING"    ("WAITING" . t))
              ("SOMEDAY"    ("WAITING" . t))
              ("TODO"       ("WAITING") ("CANCELLED"))
              ("INPROGRESS" ("WAITING"))
              ("DONE"       ("WAITING") ("CANCELLED")))))

;;; task change configurations
; keyboard shortcuts for state selection
(setq org-use-fast-todo-selection t)
; make org note the time for everytime I completed recurring tasks
(setq org-log-repeat "time")
; make org note the time for completed tasks
(setq org-log-done 'time)
; S-cursor state changes (fixing states) must not trigger updates
(setq org-treat-S-cursor-todo-selection-as-state-change nil)
; dependencies of nested TODO-items and nested checkboxes
(setq org-enforce-todo-dependencies t)
(setq org-enforce-todo-checkbox-dependencies t)

;;;
;;; Misc
;;;
; Use IDO for target completion
;(setq org-completion-use-ido t)
; src
(setq org-src-fontify-natively t)

; Targets complete in steps so we start with filename, TAB shows the next level of targets etc
(setq org-outline-path-complete-in-steps t)


;;;
;;; Clocking
;;;
;;; Clocking configuration
;; ?the following option breaks with emacs 24.3 (osx)?
;; Resume clocking tasks when emacs is restarted
(org-clock-persistence-insinuate)

;; Yes it's long... but more is better ;)
(setq org-clock-history-length 28)
;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)
;; Change task state to INPROGRESS when clocking in
(setq org-clock-in-switch-to-state (quote bh/clock-in-to-inprogress))
;; Separate drawers for clocking and logs
(setq org-drawers (quote ("PROPERTIES" "LOGBOOK" "CLOCK")))
;; Save clock data in the CLOCK drawer and state changes and notes in the LOGBOOK drawer
(setq org-clock-into-drawer "CLOCK")
;; Sometimes I change tasks I'm clocking quickly - this removes clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)
;; Clock out when moving task to a done state
(setq org-clock-out-when-done t)
;; Save the running clock and all clock history when exiting Emacs, load it on startup
(setq org-clock-persist (quote history))
;; Enable auto clock resolution for finding open clocks
(setq org-clock-auto-clock-resolution (quote when-no-clock-is-running))
;; Include current clocking task in clock reports
(setq org-clock-report-include-clocking-task t)
; clean 0 clock
(setq org-clock-out-remove-zero-time-clocks t)

;;; Clocking functons
(defun bh/clock-in ()
  (interactive)
  (setq bh/keep-clock-running t)
  (if (marker-buffer org-clock-default-task)
      (unless (org-clock-is-active)
        (bh/clock-in-default-task))
    (unless (marker-buffer org-clock-default-task)
      (org-agenda nil "c"))))

(defun bh/clock-out ()
  (interactive)
  (setq bh/keep-clock-running nil)
  (when (org-clock-is-active)
    (org-clock-out)))

(defun bh/clock-in-default-task ()
  (save-excursion
    (org-with-point-at org-clock-default-task
      (org-clock-in))))

(defun bh/clock-out-maybe ()
  (when (and bh/keep-clock-running (not org-clock-clocking-in) (marker-buffer org-clock-default-task))
    (bh/clock-in-default-task)))

(add-hook 'org-clock-out-hook 'bh/clock-out-maybe 'append)

(defun bh/clock-in-last-task ()
  "Clock in the interrupted task if there is one"
  (interactive)
  (let ((clock-in-to-task (if (org-clock-is-active)
                 (setq clock-in-to-task (cadr org-clock-history))
                 (setq clock-in-to-task (car org-clock-history)))))
    (org-with-point-at clock-in-to-task
      (org-clock-in nil))))

(defun bh/clock-in-to-inprogress (kw)
  "Switch task from TODO to INPROGRESS when clocking in.
Skips capture tasks and tasks with subtasks"
  (if (and (string-equal kw "TODO")
           (not (and (boundp 'org-capture-mode) org-capture-mode)))
      (let ((subtree-end (save-excursion (org-end-of-subtree t)))
            (has-subtask nil))
        (save-excursion
          (forward-line 1)
          (while (and (not has-subtask)
                      (< (point) subtree-end)
                      (re-search-forward "^\*+ " subtree-end t))
            (when (member (org-get-todo-state) org-not-done-keywords)
              (setq has-subtask t))))
        (when (not has-subtask)
          "INPROGRESS"))))

;; Remove empty CLOCK drawers on clock out
(defun bh/remove-empty-drawer-on-clock-out ()
  (interactive)
  (save-excursion
    (beginning-of-line 0)
    (org-remove-empty-drawer-at "CLOCK" (point))))
(add-hook 'org-clock-out-hook 'bh/remove-empty-drawer-on-clock-out 'append)


;;;
;;; Capture
;;; use org-capture to add fast todo-items to remember them later
;;;
(require 'org-capture)
(define-key global-map "\C-cc" 'org-capture)
;; Capture templates for: TODO-tasks, Notes, appointments, phone calls, and org-protocol
(setq org-capture-templates
      (quote (
              ("t" "todo" entry (file (concat my-orgfile-dir "gtd.org")) "* TODO %?
%U" :clock-in t :clock-resume t)
;%a" :clock-in t :clock-resume t)
              ("n" "note" entry (file (concat my-orgfile-dir "refile.org")) "* %?                                                                            :NOTE:
%U
%a
:CLOCK:
:END:" :clock-in t :clock-resume t)
              ("a" "appointment" entry (file+datetree (concat my-orgfile-dir "diary.org")) "* %?
%U" :clock-in t :clock-resume t)
              ("p" "Phone call" entry (file (concat my-orgfile-dir "refile.org")) "* Phone %? :PHONE:\n%U\n" :clock-in t :clock-resume t)
              ("w" "org-protocol" entry (file (concat my-orgfile-dir "refile.org")) "* TODO Review %c
%U" :immediate-finish t :clock-in t :clock-resume t))))


;;;
;;;  Remember was replaced with capture
;;;; use org-remember to add fast short memos
;;;
;; (require 'remember)
;; (setq org-remember-store-without-prompt t)
;; (setq org-remember-templates
;;       (quote
;;        (
;;         ("Todo" ?t "* TODO %^{Brief Description} %^g\n%?\nAdded: %U"
;;                   (concat my-orgfile-dir "/gtd.org") "Tasks")
;;         ("todo" ?y "* TODO %?\n %U\n %a\n :CLOCK:\n :END:" nil "Tasks" nil)
;;         ("note" ?n "* %? :NOTE:\n %U\n %a\n :CLOCK:\n :END:" nil "Notes" nil)
;;         ("appointment" ?a "* %? :APPOINTMENT:\n %U"
;;          "Appointments" nil))))


;;;
;;; refile - To refile a task to my norang.org file under System
;;;          Maintenance I just put the cursor on the task and hit C-c
;;;          C-w and enter nor TAB sys TAB RET and it's done.  List
;;;          them within Agenda mode C-c a r

; Targets include this file and any file contributing to the agenda - up to 5 levels deep
(setq org-refile-targets (quote ((org-agenda-files :maxlevel . 5) (nil
  :maxlevel . 5))))

; Targets start with the file name - allows creating level 1 tasks
(setq org-refile-use-outline-path (quote file))

; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes (quote confirm))


;;;
;;; Agenda
;;;
; Agenda functions
; bh/ functions
;
;; agenda function by http://doc.norang.ca/org-mode.html 12 GTD
(defun bh/is-project-p ()
  "Any task with a todo keyword subtask"
  (let ((has-subtask)
        (subtree-end (save-excursion (org-end-of-subtree t))))
    (save-excursion
      (forward-line 1)
      (while (and (not has-subtask)
                  (< (point) subtree-end)
                  (re-search-forward "^\*+ " subtree-end t))
        (when (member (org-get-todo-state) org-todo-keywords-1)
          (setq has-subtask t))))
    has-subtask))

(defun bh/skip-non-stuck-projects ()
  "Skip trees that are not stuck projects"
  (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
         (has-next (save-excursion
                     (forward-line 1)
                     (and (< (point) subtree-end)
                          (re-search-forward "^\\*+ INPROGRESS " subtree-end t)))))
    (if (and (bh/is-project-p) (not has-next))
        nil ; a stuck project, has subtasks but no next task
      subtree-end)))

(defun bh/skip-non-projects ()
  "Skip trees that are not projects"
  (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
    (if (bh/is-project-p)
        nil
      subtree-end)))

(defun bh/skip-projects ()
  "Skip trees that are projects"
  (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
    (if (bh/is-project-p)
        subtree-end
      nil)))

; Erase all reminders and rebuilt reminders for today from the agenda
(defun bh/org-agenda-to-appt ()
  (interactive)
  (setq appt-time-msg-list nil)
  (org-agenda-to-appt))

;;;
;;; config of Agenda, view with C-c a
;;;
; warn 7 day before deadline ends, p.e. within Agenda
(setq org-deadline-warning-days 7)

; Agenda log mode items to display (clock time only by default)
(setq org-agenda-log-mode-items (quote (clock)))
; include diary within agenda views
(setq org-agenda-include-diary t)
; Agenda clock report parameters (no links, 2 levels deep)
;; Agenda clock report parameters
(setq org-agenda-clockreport-parameter-plist
      (quote (:link t :maxlevel 5 :fileskip0 t :compact t :narrow 80)))
;(setq org-agenda-clockreport-parameter-plist (quote (:link nil :maxlevel 2)))
; Set default column view headings: Task Effort Clock_Summary
(setq org-columns-default-format "%80ITEM(Task) %10Effort(Effort){:} %10CLOCKSUM")
;; Keep tasks with dates off the global todo-lists
(setq org-agenda-todo-ignore-with-date nil)
;; Allow deadlines which are due soon to appear on the global-todo
;; lists
(setq org-agenda-todo-ignore-deadlines (quote far))
;; Keep tasks scheduled in the future off the global todo-lists
(setq org-agenda-todo-ignore-scheduled (quote future))
;; Remove completed deadline tasks from the agenda view
(setq org-agenda-skip-deadline-if-done t)
;; Remove completed scheduled tasks from the agenda view
(setq org-agenda-skip-scheduled-if-done t)
;; Remove completed items from search results
(setq org-agenda-skip-timestamp-if-done t)

;;;
;;; Agenda views and shortcuts
;;;
(setq org-agenda-custom-commands
  '(("O" "Office block agenda"
       ((agenda "" (
         (org-agenda-ndays 7)                     ;; 7 days agenda
         (org-deadline-warning-days 14)           ;; 14 day advanced warning for deadlines
         (org-agenda-start-on-weekday nil)        ;; calendar begins today
         (org-agenda-scheduled-leaders '("" ""))
         (org-agenda-prefix-format "%t%s")
       ))
       (todo "TODO"                               ;; todos sorted by context
        ((org-agenda-prefix-format "[ ] %T: ")
         (org-agenda-sorting-strategy '(tag-up priority-down))
         (org-agenda-todo-keyword-format "")
         (org-agenda-with-colors nil)
         (org-agenda-compact-blocks t)
         (org-agenda-remove-tags t)
         (org-agenda-overriding-header "\nTasks by Context\n------------------\n")))
    ) nil ("agenda_office.html" "agenda_office.txt" "agenda_office.ps")) ; "agenda_office.ics")) ; C-c a e

;; TODO: customize following Agenda listings to fit my needs
    ("P" "Printed agenda"
      ((agenda "" (
         (org-agenda-ndays 7)                     ;; overview of appointments
         (org-agenda-start-on-weekday nil)        ;; calendar begins today
         (org-agenda-repeating-timestamp-show-all t)
         (org-agenda-entry-types '(:timestamp :sexp))))
       (agenda "" (
         (org-agenda-ndays 1)                     ;; daily agenda
         (org-deadline-warning-days 7)            ;; 7 day advanced warning for deadlines
         (org-agenda-todo-keyword-format "[ ]")
         (org-agenda-scheduled-leaders '("" ""))
         (org-agenda-prefix-format "%t%s")))
       (todo "TODO"                               ;; todos sorted by context
        ((org-agenda-prefix-format "[ ] %T: ")
         (org-agenda-sorting-strategy '(tag-up priority-down))
         (org-agenda-todo-keyword-format "")
         (org-agenda-overriding-header "\nTasks by Context\n------------------\n"))))
      ((org-agenda-with-colors nil)
       (org-agenda-compact-blocks t)
       (org-agenda-remove-tags t)
       (ps-number-of-columns 2)
       (ps-landscape-mode t))
      ("~/agenda.ps"))
    ("D" "Develop" tags-todo "/!OPEN"
         ((org-agenda-overriding-header "Develop")))
    ("w" "Tasks waiting on something" tags "WAITING/!"
     ((org-use-tag-inheritance nil)
      (org-agenda-todo-ignore-scheduled nil)
      (org-agenda-todo-ignore-deadlines nil)
      (org-agenda-todo-ignore-with-date nil)
      (org-agenda-overriding-header "Waiting Tasks")))
    ("i" "InProgress" tags-todo "/!INPROGRESS"
     ((org-agenda-overriding-header "Tasks that are started, but not finished")))

    ("r" "Refile New Notes and Tasks" tags "LEVEL=1+REFILE"
     ((org-agenda-todo-ignore-with-date nil)
      (org-agenda-todo-ignore-deadlines nil)
      (org-agenda-todo-ignore-scheduled nil)
      (org-agenda-overriding-header "Tasks to Refile")))
    ("N" "Notes" tags "NOTE"
     ((org-agenda-overriding-header "Notes")))

    ; useful? - see http://doc.norang.ca/org-mode.html
    ("p" "Projects" tags-todo "LEVEL=2-REFILE|LEVEL=1+REFILE/!-DONE-CANCELLED"
     ((org-agenda-skip-function 'bh/skip-non-projects)
      (org-agenda-overriding-header "Projects")))
    ("o" "Other (Non-Project) tasks" tags-todo "LEVEL=2-REFILE|LEVEL=1+REFILE/!-DONE-CANCELLED"
     ((org-agenda-skip-function 'bh/skip-projects)
      (org-agenda-overriding-header "Other Non-Project Tasks")))
    ("A" "Tasks to be Archived" tags "LEVEL=2-REFILE/DONE|CANCELLED"
     ((org-agenda-overriding-header "Tasks to Archive")))
    ("h" "Habits" tags "STYLE=\"habit\""
     ((org-agenda-todo-ignore-with-date nil)
      (org-agenda-todo-ignore-scheduled nil)
      (org-agenda-todo-ignore-deadlines nil)
      (org-agenda-overriding-header "Habits")))
    ("#" "Stuck Projects" tags-todo "LEVEL=2-REFILE|LEVEL=1+REFILE/!-DONE-CANCELLED"
     ((org-agenda-skip-function 'bh/skip-non-stuck-projects)
      (org-agenda-overriding-header "Stuck Projects")))
    ("c" "Select default clocking task" tags "LEVEL=2-REFILE"
     ((org-agenda-skip-function
       '(org-agenda-skip-subtree-if 'notregexp "^\\*\\* Organization"))
                      (org-agenda-overriding-header "Set default clocking task with C-u C-u I")))
    ;; other commands go here
    )
)


;;; Appt - reminder
;;; reminder with appt
;;;
; Rebuild the reminders everytime the agenda is displayed
(add-hook 'org-finalize-agenda-hook 'bh/org-agenda-to-appt)
; This is at the end of my .emacs - so appointments are set up when Emacs starts
(bh/org-agenda-to-appt)
; Activate appointments so we get notifications
(appt-activate t)
; If we leave Emacs running overnight - reset the appointments one minute after midnight
(run-at-time "24:01" nil 'bh/org-agenda-to-appt)

;;;; auto clocking is a bit messy..
(setq bh/keep-clock-running nil)


;;;
;;; tagging
;;;
(setq org-tag-alist
      (quote ((:startgroup)
              ("@office" . ?o)
              ("@home" . ?h)
              ("@elsewhere" . ?e)
              (:endgroup)
              (:startgroup)
              ("ruby" . ?r)
              ("coding" . ?c)
              ("framework" . ?f)
              (:endgroup)
              ("PHONE" . ?P)
              ("WAITING" . ?w)
              ("HOME" . ?H)
              ("ORG" . ?O)
              ("MARK" . ?M)
              ("NOTE" . ?n)
              ("CANCELLED" . ?C))))

; Allow setting single tags without the menu
;(setq org-fast-tag-selection-single-key (quote expert))



;;;
;;; org-babel for graphics and computer languages
;;;
(add-hook 'org-babel-after-execute-hook 'org-display-inline-images)
(require 'ob-R)
; ditaa
(require 'ob-ditaa)
(unless (not is-darwin)
  (setq org-ditaa-jar-path "/usr/local/Cellar/ditaa/0.9/libexec/ditaa0_9.jar"))
; UML with plantuml
(setq org-plantuml-jar-path
      (expand-file-name "~/src/plantuml/plantuml.jar"))
; colored code with babel
(org-babel-do-load-languages
  'org-babel-load-languages
  '((emacs-lisp . t)
         (calc . t)
         (clojure . t)
         (css . t)
         (dot . t)
         (ditaa . t)
         (gnuplot . t)
         (js . t)
         (latex . t)
         (plantuml . t)
         (python . t)
         (R . t)
         (ruby . t)
    ;     (sh . t)
         (sql . t)))

;; code block fontification
(setq org-src-fontify-natively t)
(setq org-src-tab-acts-natively t)

;; Do not prompt to confirm evaluation.
;; This may be dangerous - make sure you understand the consequences
;; of setting this -- see the docstring for details.
(setq org-confirm-babel-evaluate nil)


;;; Mobile-Org
;;; org-mobile - I use a symlink to export my org folder with WebDAV
;;;
; org-mobile-push / org-mobile-pull
(setq org-directory "~/org")
;(setq org-mobile-directory "/Library/WebServer/WebDAV/org")
; mobile org encryption (transparent encryption/decryption using sharedkey)
(setq org-mobile-use-encryption t)
(setq org-mobile-encryption-password "a_password")

;;; Manpage integration
;;; org-man provides links to manpages, example: man:ls
;;;
(add-to-list 'load-path (concat my-libs-dir "org-man"))
(require 'org-man)

;
;
; last stmt
(setq org-log-done t)
