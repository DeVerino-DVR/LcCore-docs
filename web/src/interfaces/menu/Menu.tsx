import { useState, useEffect, useRef, useCallback } from 'react'
import { fetchNui } from '../../hooks/useNui'
import s from './Menu.module.css'

export interface MenuItem {
  label: string
  type?: 'default' | 'separator' | 'text'
  rightLabel?: string
  description?: string
  values?: string[]
  defaultIndex?: number
  checked?: boolean
  disabled?: boolean
  close?: boolean
}

export interface MenuProps {
  id?: string
  title: string
  subtitle?: string
  items: MenuItem[]
  position?: 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right'
  maxVisibleItems?: number
  canClose?: boolean
  onSelect?: (index: number, scrollIndex: number) => void
  onClose?: () => void
  onIndexChange?: (index: number, scrollIndex: number) => void
}

const ITEM_HEIGHT = 48
const MAX_VISIBLE = 11

export default function Menu({
  title,
  subtitle,
  items,
  position = 'top-left',
  maxVisibleItems,
  canClose = true,
  onSelect,
  onClose,
  onIndexChange,
}: MenuProps) {
  const maxItems = Math.min(maxVisibleItems || MAX_VISIBLE, 20)
  const [selected, setSelected] = useState(0)
  const [closing, setClosing] = useState(false)
  const [indexStates, setIndexStates] = useState<Record<number, number>>({})
  const [checkedStates, setCheckedStates] = useState<Record<number, boolean>>({})
  const containerRef = useRef<HTMLDivElement>(null)
  const windowStartRef = useRef(0)

  // Init states
  useEffect(() => {
    const idxs: Record<number, number> = {}
    const chks: Record<number, boolean> = {}
    items.forEach((item, i) => {
      if (item.values) idxs[i] = (item.defaultIndex || 1) - 1
      if (item.checked !== undefined) chks[i] = item.checked
    })
    setIndexStates(idxs)
    setCheckedStates(chks)

    // Skip to first non-separator non-disabled
    let start = 0
    while ((items[start]?.type === 'separator' || items[start]?.disabled) && start < items.length - 1) start++
    setSelected(start)
  }, [items])

  // Scroll window
  if (selected < windowStartRef.current) {
    windowStartRef.current = selected
  } else if (selected >= windowStartRef.current + maxItems) {
    windowStartRef.current = selected - maxItems + 1
  }
  if (windowStartRef.current + maxItems > items.length) {
    windowStartRef.current = Math.max(0, items.length - maxItems)
  }

  const needsScroll = items.length > maxItems
  const totalHeight = needsScroll ? maxItems * ITEM_HEIGHT : items.length * ITEM_HEIGHT
  const scrollOffset = windowStartRef.current * ITEM_HEIGHT

  const findNext = useCallback((current: number, dir: 'up' | 'down') => {
    let next = current
    let attempts = 0
    do {
      next = dir === 'down'
        ? (next >= items.length - 1 ? 0 : next + 1)
        : (next <= 0 ? items.length - 1 : next - 1)
      attempts++
    } while ((items[next]?.type === 'separator' || items[next]?.disabled) && attempts < items.length)
    return next
  }, [items])

  const close = useCallback(() => {
    if (!canClose) return
    setClosing(true)
    setTimeout(() => {
      onClose?.()
      fetchNui('closeMenu').catch(() => {})
    }, 200)
  }, [canClose, onClose])

  // Keyboard
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      switch (e.code) {
        case 'ArrowDown':
          e.preventDefault()
          setSelected(prev => findNext(prev, 'down'))
          break
        case 'ArrowUp':
          e.preventDefault()
          setSelected(prev => findNext(prev, 'up'))
          break
        case 'ArrowRight':
          if (items[selected]?.values) {
            setIndexStates(prev => {
              const max = items[selected].values!.length - 1
              const next = prev[selected] + 1 > max ? 0 : prev[selected] + 1
              return { ...prev, [selected]: next }
            })
          }
          break
        case 'ArrowLeft':
          if (items[selected]?.values) {
            setIndexStates(prev => {
              const max = items[selected].values!.length - 1
              const next = prev[selected] - 1 < 0 ? max : prev[selected] - 1
              return { ...prev, [selected]: next }
            })
          }
          break
        case 'Enter':
          if (items[selected]?.disabled) return
          if (items[selected]?.type === 'separator') return
          if (items[selected]?.checked !== undefined) {
            setCheckedStates(prev => {
              const next = { ...prev, [selected]: !prev[selected] }
              fetchNui('changeChecked', [selected, next[selected]]).catch(() => {})
              return next
            })
            return
          }
          onSelect?.(selected, indexStates[selected] ?? 0)
          fetchNui('confirmSelected', [selected, indexStates[selected] ?? 0]).catch(() => {})
          if (items[selected]?.close !== false) close()
          break
        case 'Escape':
        case 'Backspace':
          close()
          break
      }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [selected, items, indexStates, findNext, close, onSelect])

  // Notify index change
  useEffect(() => {
    onIndexChange?.(selected, indexStates[selected] ?? 0)
  }, [selected, indexStates])

  // Position styles
  const posStyle: React.CSSProperties = {
    marginTop: position.startsWith('top') ? 30 : 0,
    marginLeft: position.endsWith('left') ? 50 : 0,
    marginRight: position.endsWith('right') ? 30 : 0,
    marginBottom: position.startsWith('bottom') ? 30 : 0,
    right: position.endsWith('right') ? 1 : undefined,
    bottom: position.startsWith('bottom') ? 1 : undefined,
  }

  // Description
  const currentDesc = items[selected]?.values
    ? undefined
    : items[selected]?.description

  // Counter (non-separator items only)
  const nonSepItems = items.filter(it => it.type !== 'separator')
  let currentNonSepIdx = 0
  for (let i = 0; i < selected; i++) {
    if (items[i]?.type !== 'separator') currentNonSepIdx++
  }

  return (
    <div
      className={closing ? s.wrapperClosing : s.wrapper}
      style={posStyle}
      ref={containerRef}
    >
      <div className={s.container}>
        {/* Header */}
        <div className={s.header}>
          <span className={s.headerTitle}>{title}</span>
        </div>

        {/* Subtitle */}
        <div className={s.subtitleBar}>
          <span className={s.subtitleText}>{subtitle || title}</span>
        </div>

        {/* Items - hauteur fixe */}
        <div className={s.itemsWrapper} style={{ height: totalHeight }}>
          <div style={{ transform: `translateY(-${scrollOffset}px)` }}>
            {items.map((item, index) => {
              const isFocused = selected === index

              if (item.type === 'separator') {
                return (
                  <div key={index} className={s.separator}>
                    <span className={s.separatorText}>{item.label}</span>
                  </div>
                )
              }

              return (
                <div
                  key={index}
                  className={`${s.item} ${isFocused ? s.itemFocused : ''} ${item.disabled ? s.itemDisabled : ''}`}
                  onClick={() => {
                    if (item.disabled) return
                    setSelected(index)
                    if (item.checked !== undefined) {
                      setCheckedStates(prev => {
                        const next = { ...prev, [index]: !prev[index] }
                        fetchNui('changeChecked', [index, next[index]]).catch(() => {})
                        return next
                      })
                      return
                    }
                    onSelect?.(index, indexStates[index] ?? 0)
                    fetchNui('confirmSelected', [index, indexStates[index] ?? 0]).catch(() => {})
                    if (item.close !== false) close()
                  }}
                  onMouseEnter={() => !item.disabled && setSelected(index)}
                >
                  {isFocused && !item.disabled && <div className={s.selectedBorder} />}
                  <div className={s.itemContent}>
                    {/* Left: label */}
                    <span className={`${s.itemLabel} ${isFocused ? s.itemLabelFocused : ''}`}>
                      {item.label}
                    </span>

                    {/* Right side */}
                    <div className={s.itemRight}>
                      {item.values ? (
                        <>
                          <span className={`${s.chevron} ${isFocused ? s.chevronFocused : ''}`}>‹</span>
                          <span className={`${s.scrollValue} ${isFocused ? s.scrollValueFocused : ''}`}>
                            {item.values[indexStates[index] ?? 0]}
                          </span>
                          <span className={`${s.chevron} ${isFocused ? s.chevronFocused : ''}`}>›</span>
                        </>
                      ) : item.checked !== undefined ? (
                        <div className={`${s.checkbox} ${checkedStates[index] ? s.checkboxChecked : ''}`}>
                          {checkedStates[index] && <span>✕</span>}
                        </div>
                      ) : item.type === 'text' ? (
                        <input
                          className={`${s.textInput} ${isFocused ? s.textInputFocused : ''}`}
                          type="text"
                          defaultValue=""
                          placeholder="..."
                          onClick={(e) => e.stopPropagation()}
                        />
                      ) : item.rightLabel ? (
                        <span className={`${s.rightLabel} ${isFocused ? s.rightLabelFocused : ''}`}>
                          {item.rightLabel}
                        </span>
                      ) : (
                        <span className={`${s.arrows} ${isFocused ? s.arrowsFocused : ''}`}>›››</span>
                      )}
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        {/* Counter */}
        {nonSepItems.length > 0 && (
          <div className={s.counterBar}>
            <span className={s.counterText}>{currentNonSepIdx + 1} of {nonSepItems.length}</span>
          </div>
        )}

        {/* Description - hauteur fixe 280px */}
        <div className={s.descriptionZone}>
          {currentDesc && (
            <div className={s.descriptionText}>{currentDesc}</div>
          )}
        </div>

        {/* Footer */}
        <img src="/divider/line_divider_top.png" className={s.divider} alt="" />
        <div className={s.copyright}>© Last Country</div>
      </div>
    </div>
  )
}
