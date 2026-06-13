#!/usr/bin/env node
const { Command } = require('commander')
const https = require('https')
const http = require('http')

const API_URL = process.env.HIPPOCAMPUS_URL || 'http://hippocampus.zea.localhost'
const API_KEY = process.env.HIPPOCAMPUS_KEY || process.env.ZEA_HIPPOCAMPUS_KEY || ''

function request(method, path, body) {
  const url = new URL(API_URL + '/api/v1' + path)
  const mod = url.protocol === 'https:' ? https : http
  return new Promise((resolve, reject) => {
    const opts = {
      hostname: url.hostname, port: url.port, path: url.pathname,
      method, headers: { 'Content-Type': 'application/json', 'x-api-key': API_KEY }
    }
    const req = mod.request(opts, res => {
      let data = ''
      res.on('data', c => data += c)
      res.on('end', () => resolve({ status: res.statusCode, data: JSON.parse(data || '{}') }))
    })
    req.on('error', reject)
    if (body) req.write(JSON.stringify(body))
    req.end()
  })
}

const program = new Command()
program.name('zea-hippocampus').description('ZEA Hippocampus — Preview Environment Manager').version('0.1.0')

program.command('list')
  .description('List active previews')
  .action(async () => {
    const { status, data } = await request('GET', '/previews')
    if (data.data) {
      for (const p of data.data) {
        console.log(`${p.status === 'running' ? '🟢' : '🔴'} ${p.slug.padEnd(25)} ${p.branch.padEnd(20)} ${p.url || ''}`)
      }
    } else {
      console.log('No previews found')
    }
  })

program.command('create')
  .description('Create a new preview environment')
  .requiredOption('--branch <branch>', 'Git branch to preview')
  .option('--repo <repo>', 'Repository name', 'sudlich-app')
  .action(async (opts) => {
    const { status, data } = await request('POST', '/previews', { branch: opts.branch, repo: opts.repo })
    if (data.data) {
      console.log(`✅ Preview created: ${data.data.slug}`)
      console.log(`   URL: ${data.data.url}`)
    } else {
      console.error('❌', data.error || 'Unknown error')
    }
  })

program.command('destroy')
  .description('Destroy a preview environment')
  .requiredOption('--slug <slug>', 'Preview slug')
  .action(async (opts) => {
    const { status } = await request('DELETE', `/previews/${opts.slug}`)
    console.log(status === 200 ? `✅ Destroyed ${opts.slug}` : '❌ Failed')
  })

program.command('logs')
  .description('Get logs from a preview')
  .requiredOption('--slug <slug>', 'Preview slug')
  .action(async (opts) => {
    const { status, data } = await request('GET', `/previews/${opts.slug}/logs`)
    console.log(data.logs || 'No logs')
  })

program.command('restart')
  .description('Restart a preview')
  .requiredOption('--slug <slug>', 'Preview slug')
  .action(async (opts) => {
    const { status } = await request('POST', `/previews/${opts.slug}/restart`)
    console.log(status === 200 ? `✅ Restarted ${opts.slug}` : '❌ Failed')
  })

program.parse()
