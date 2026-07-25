import type React from 'react';
import { Search, LogOut, X } from 'lucide-react';
import type { View, NavItem } from '../types';

export function Shell({
  activeView,
  onNavigate,
  onLogout,
  brandTitle,
  brandSubtitle,
  searchPlaceholder,
  searchValue,
  onSearchChange,
  onSearchClear,
  topIcons,
  children,
  sidebarItems,
  footerAction,
  footerActionClassName,
  footerActionIcon,
  footerActionLabel,
  footerUser,
  topbarClassName,
  shellClassName,
  sidebarClassName,
  showSidebarLinks = true,
  showFooterUser = true,
  showSignOut = true,
}: {
  activeView: View;
  onNavigate: (view: View) => void;
  onLogout: () => void;
  brandTitle: string;
  brandSubtitle: string;
  searchPlaceholder: string;
  searchValue?: string;
  onSearchChange?: (val: string) => void;
  onSearchClear?: () => void;
  topIcons: React.ReactNode;
  children: React.ReactNode;
  sidebarItems: NavItem[];
  footerAction?: () => void;
  footerActionClassName?: string;
  footerActionIcon?: React.ReactNode;
  footerActionLabel?: string;
  footerUser?: { name: string; role: string };
  topbarClassName?: string;
  shellClassName?: string;
  sidebarClassName?: string;
  showSidebarLinks?: boolean;
  showFooterUser?: boolean;
  showSignOut?: boolean;
}) {
  return (
    <div className={`screen-shell ${shellClassName ?? ''}`.trim()}>
      <aside className={`sidebar ${sidebarClassName ?? ''}`.trim()}>
        <div>
          <div className="sidebar-header">
            <div className="sidebar-brand">
              <div>
                <div className="sidebar-title">{brandTitle}</div>
                <div className="sidebar-subtitle">{brandSubtitle}</div>
              </div>
            </div>
          </div>
          <nav className="sidebar-nav">
            {sidebarItems.map((item) => (
              <button key={item.view} className={`nav-item ${activeView === item.view ? 'active' : ''}`} onClick={() => onNavigate(item.view)}>
                {item.icon}
                <span>{item.label}</span>
              </button>
            ))}
          </nav>
        </div>

        <div className="sidebar-bottom">
          {footerUser && showFooterUser && (
            <div className="sidebar-user">
              <div className="avatar">A</div>
              <div>
                <div className="user-name">{footerUser.name}</div>
                <div className="user-role">{footerUser.role}</div>
              </div>
            </div>
          )}
          {showSignOut && (
            <button className="side-logout" type="button" onClick={onLogout}>
              <LogOut size={16} />
              Sign Out
            </button>
          )}
        </div>
      </aside>

      <main className={`main-shell ${topbarClassName ?? ''}`}>
        <header className="top-row">
          <div className="topbar-brand">RASAC Framework</div>
          <div className="top-actions">
            <div className="search-box">
              <Search size={16} />
              <input
                placeholder={searchPlaceholder}
                value={searchValue ?? ''}
                onChange={(e) => onSearchChange?.(e.target.value)}
                aria-label={searchPlaceholder}
              />
              {searchValue && (onSearchClear || onSearchChange) && (
                <button
                  type="button"
                  className="student-search-clear"
                  aria-label="Clear search"
                  onClick={() => {
                    if (onSearchClear) onSearchClear();
                    else onSearchChange?.('');
                  }}
                >
                  <X size={11} />
                </button>
              )}
            </div>
            {topIcons}
          </div>
        </header>
        {children}
      </main>
    </div>
  );
}

